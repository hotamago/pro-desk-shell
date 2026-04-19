import { exit, programArgs, programInvocationName } from "system";
import GLib from "gi://GLib?version=2.0";

async function importGIRepository() {
  try {
    const module = await import("gi://GIRepository?version=2.0");
    return module.default ?? module;
  } catch (_error) {
    const module = await import("gi://GIRepository?version=3.0");
    return module.default ?? module;
  }
}

function locateAgsLibdir() {
  const candidates = [
    GLib.getenv("AGS_LIBDIR"),
    "/usr/lib64/ags",
    "/usr/lib/ags",
  ].filter(Boolean);

  const found = candidates.find((candidate) =>
    GLib.file_test(candidate, GLib.FileTest.IS_DIR),
  );

  if (!found) {
    throw new Error("Could not locate AGS libdir. Set AGS_LIBDIR.");
  }

  return found;
}

function configureRepository(GIRepository, libdir) {
  const Repository = GIRepository.Repository;
  if (!Repository) {
    throw new Error("GIRepository.Repository is unavailable.");
  }

  if (typeof Repository.prepend_search_path === "function") {
    Repository.prepend_search_path(libdir);
    Repository.prepend_library_path(libdir);
    return;
  }

  const defaultRepo =
    (typeof Repository.dup_default === "function" && Repository.dup_default()) ||
    (typeof Repository.get_default === "function" && Repository.get_default()) ||
    null;

  if (!defaultRepo) {
    throw new Error("Could not resolve default GIRepository instance.");
  }

  if (
    typeof defaultRepo.prepend_search_path !== "function" ||
    typeof defaultRepo.prepend_library_path !== "function"
  ) {
    throw new Error("Default GIRepository instance cannot prepend paths.");
  }

  defaultRepo.prepend_search_path(libdir);
  defaultRepo.prepend_library_path(libdir);
}

function resolveForwardedArgs() {
  const raw = GLib.getenv("PRO_DESK_SHELL_AGS_ARGS");
  if (!raw || raw.trim().length === 0) {
    return programArgs;
  }

  const parsed = GLib.shell_parse_argv(raw);
  return parsed[1] ?? [];
}

const GIRepository = await importGIRepository();
const libdir = locateAgsLibdir();
const prefix = GLib.path_get_dirname(GLib.path_get_dirname(libdir));

imports.package.init({
  name: "com.github.Aylur.ags",
  version: GLib.getenv("AGS_VERSION") ?? "1.9.0",
  prefix,
  libdir,
});

configureRepository(GIRepository, libdir);

const module = await import("resource:///com/github/Aylur/ags/main.js");
const exitCode = await module.main([programInvocationName, ...resolveForwardedArgs()]);
exit(exitCode);
