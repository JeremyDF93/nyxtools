#if defined _nyxtools_cheats_included
  #endinput
#endif
#define _nyxtools_cheats_included

/**
 * Executes a cheat command on the server without being networked. This bypasses
 * the sv_cheats cvar without changing it.
 *
 * @param client        Index of the client.
 * @param fmt           Format of the client command.
 * @param ...           Format parameters
 * @error               Invalid client index
 */
native void FakeClientCommandCheat(int client, const char[] fmt, any ...);

/**
 * Returns true if the client has access to cheat commands.
 *
 * @param client        Index of the client.
 * @return              True if they hace access to cheats
 */
native bool HasCheatPermissions(int client);

public SharedPlugin:__pl_nyxtools_cheats = {
  name = "nyxtools_cheats",
  file = "nyxtools_cheats.smx",
#if defined REQUIRE_PLUGIN
  required = 1,
#else
  required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_nyxtools_cheats_SetNTVOptional() {
  MarkNativeAsOptional("FakeClientCommandCheat");
  MarkNativeAsOptional("HasCheatPermissions");
}
#endif
