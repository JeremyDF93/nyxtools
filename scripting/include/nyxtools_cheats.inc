#if defined _nyxtools_cheats_included
  #endinput
#endif
#define _nyxtools_cheats_included

native void FakeClientCommandCheat(int client, const char[] cmd, const char[] args);
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
