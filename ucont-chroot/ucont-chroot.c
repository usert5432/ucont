#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef CONTAINERS_ROOT
#define CONTAINERS_ROOT "/run/ucont/"
#endif

#ifdef USE_CAPS
#include <sys/capability.h>
#endif

void acquire_priveleges()
{
#ifdef USE_CAPS
    cap_value_t cap_list[1] = { CAP_SYS_CHROOT };

    cap_t caps = cap_get_proc();
    if (caps == NULL) {
        goto error;
    }

    if (! CAP_IS_SUPPORTED(cap_list[0])) {
        goto error;
    }

    if (cap_set_flag(caps, CAP_EFFECTIVE, 1, cap_list, CAP_SET) != 0) {
        goto error;
    }

    if (cap_set_proc(caps) != 0) {
        goto error;
    }

    if (cap_free(caps) != 0) {
        goto error;
    }

    return;

error:
    perror("Failed to acquire chroot capability");
    cap_free(caps);
    exit(EXIT_FAILURE);
#endif
}

void drop_suid()
{
#ifdef USE_SUID
    uid_t real_uid = getuid();
    if (setuid(real_uid) != 0) {
        goto error;
    }

    return;

error:
    perror("Failed to drop suid");
    exit(EXIT_FAILURE);
#endif
}

void drop_caps()
{
#ifdef USE_CAPS
    cap_t caps = cap_get_proc();

    if (caps == NULL) {
        goto error;
    }

    if (cap_clear(caps) != 0) {
        goto error;
    }

    if (cap_set_proc(caps) != 0) {
        goto error;
    }

    if (cap_free(caps) != 0) {
        goto error;
    }

    return;

error:
    perror("Failed to drop capabilities");
    cap_free(caps);
    exit(EXIT_FAILURE);
#endif
}

void drop_priveleges()
{
    drop_suid();
    drop_caps();
}

void exec_chroot(const char *path)
{
    if (chroot(path) != 0)
    {
        perror("Failed to chroot");
        exit(EXIT_FAILURE);
    }
}

void exec_chdir(const char *workdir)
{
    if (chdir("/") != 0)
    {
        perror("Failed to change working directory");
        exit(EXIT_FAILURE);
    }

    if (chdir(workdir) != 0) {
        perror("Failed to restore working directory");
    }
}

void usage ()
{
    puts("USAGE: ucont-chroot DIRECTORY CMD [ARGS...]");
}

size_t calculate_path_depth(const char *path)
{
    const char *c = path;

    size_t depth = 0;
    bool   reading_separators = true;

    while ((*c) != '\0')
    {
        if ((*c) == '/') {
            reading_separators = true;
        }
        else {
            if (reading_separators) {
                reading_separators = false;
                depth++;
            }
        }

        c++;
    }

    return depth;
}

/*
 * This function verifies that the path `path` has form
 * CONTAINERS_ROOT/COMPONENT1/COMPONENT2
 */
bool verify_path(const char *path, const char *containers_root)
{
    const char *actual   = path;
    const char *expected = containers_root;

    while ((*expected) != '\0')
    {
        if ((*actual) != (*expected)) {
            fprintf(
                stderr, "Supplied path '%s' is not inside '%s'\n",
                path, CONTAINERS_ROOT
            );
            return false;
        }

        expected++;
        actual++;
    }

    const size_t depth = calculate_path_depth(actual);
    if (depth != 2) {
        fprintf(
            stderr, "Supplied path '%s' depth %lu in '%s' is not 2\n",
            path, depth, CONTAINERS_ROOT
        );

        return false;
    }

    return true;
}

/*
 * NOTE: Possible race condition here.
 * After path verification has successfully completed, an unprivileged user can
 * remove `real_path` and create a symlink `real_path` -> pointing to whatever
 * path he likes. This will allow the user to chroot into any directory
 * bypassing the requirement that it should be inside CONTAINERS_ROOT.
 *
 * The only protection I see is to make sure that the allowed paths are only
 * root writable, preventing an unpriveleged user to mangle with them.
 */

/* NOTE: transfers ownership */
char* resolve_and_verify_path(const char *path)
{
    char *real_path       = realpath(path, NULL);
    char *containers_root = realpath(CONTAINERS_ROOT, NULL);

    if (real_path == NULL) {
        perror("Failed to resolve path");
        goto error;
    }

    if (containers_root == NULL) {
        perror("Failed to resolve containers ROOT path.");
        goto error;
    }

    if (! verify_path(real_path, containers_root)) {
        goto error;
    }

    free(containers_root);
    return real_path;

error:
    free(real_path);
    free(containers_root);
    exit(EXIT_FAILURE);
}

int main(int argc, char* argv[])
{
    if (argc < 3)
    {
        usage();
        fputs("Error: Not enough arguments provided\n", stderr);
        exit(EXIT_FAILURE);
    }

    char *old_workdir     = getcwd(NULL, 0);
    const char *path      = argv[1];
    const char *cmd       = argv[2];
    char* const *cmd_argv = &argv[2];
    char *real_path       = resolve_and_verify_path(path);

    acquire_priveleges();
    exec_chroot(real_path);
    drop_priveleges();

    exec_chdir(old_workdir);

    free(old_workdir);
    free(real_path);

    if (execvp(cmd, cmd_argv) == -1)
    {
        perror("Failed to exec");
        fprintf(stderr, "Exec cmd: %s\n", cmd);

        exit(EXIT_FAILURE);
    }
}

