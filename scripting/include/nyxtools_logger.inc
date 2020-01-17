#if defined _nyxtools_logger_included
  #endinput
#endif
#define _nyxtools_logger_included

#include <nyxtools>

#if !defined NYXTOOLS_TAG
  #define NYXTOOLS_TAG "Nyx"
#endif

char nyx_prefix[16];

methodmap Logger __nullable__ {
  public Logger(const char[] prefix="[Nyx]") {
    strcopy(nyx_prefix, sizeof(nyx_prefix), prefix);

    return view_as<Logger>(0);
  }

  public void server(const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 3);

    PrintToServer("%s %s", nyx_prefix, buffer);
  }

  public void console(int client, const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 4);

    PrintToConsole(client, "%s %s", nyx_prefix, buffer);
  }

  public void chat(int client, const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 4);

    PrintToChat(client, "%s %s", nyx_prefix, buffer);
  }

  public void all(const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 3);

    PrintToChatAll("%s %s", nyx_prefix, buffer);
  }

  public void act(int client, const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 4);

    char prefix[16];
    FormatEx(prefix, sizeof(prefix), "%s ", nyx_prefix);

    ShowActivity2(client, prefix, "%s", buffer);
  }

  public void team(int team, const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 4);

    for (int i = 1; i <= MaxClients; i++) {
      if (!IsValidClient(i, true)) continue;
      if (GetClientTeam(i) != team) continue;

      this.chat(i, buffer);
    }
  }

  public void admin(const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 3);

    for (int i = 1; i <= MaxClients; i++) {
      if (!IsValidClient(i, true)) continue;
      if (!IsClientAdmin(i)) continue;

      this.chat(i, buffer);
      this.console(i, buffer);
    }

    this.server(buffer);
  }

  public void reply(int client, const char[] fmt, any ...) {
    char buffer[255];
    VFormat(buffer, sizeof(buffer), fmt, 4);

    ReplySource rs = GetCmdReplySource();
    if (rs == SM_REPLY_TO_CONSOLE) {
      this.console(client, buffer);
    } else {
      this.chat(client, buffer);
    }
  }

  public void debug(const char[] fmt, any ...) {
#if defined _DEBUG
    char buffer[256];
    VFormat(buffer, sizeof(buffer), fmt, 3);

    this.server(buffer);
#endif
  }
}

stock void NyxMsg(const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  PrintToServer("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgReply(int client, const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  ReplySource rs = GetCmdReplySource();
  if (rs == SM_REPLY_TO_CONSOLE) {
    NyxMsgConsole(client, buffer);
  } else {
    NyxMsgClient(client, buffer);
  }
}

stock void NyxMsgConsole(int client, const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  PrintToConsole(client, "[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgClient(int client, const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  PrintToChat(client, "[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgAll(const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  PrintToChatAll("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgTeam(int team, const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (GetClientTeam(i) != team) continue;

    PrintToChat(i, "[%s] %s", NYXTOOLS_TAG, buffer);
    PrintToConsole(i, "[%s] %s", NYXTOOLS_TAG, buffer);
  }
}

stock void NyxMsgAdmin(const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (!IsClientAdmin(i)) continue;

    PrintToChat(i, "[%s] %s", NYXTOOLS_TAG, buffer);
    PrintToConsole(i, "[%s] %s", NYXTOOLS_TAG, buffer);
  }

  PrintToServer("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgDebug(const char[] format, any ...) {
#if defined NYXTOOLS_DEBUG
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  // use a switch statement because you'll 'redundant code' warnings in the compiler
  switch (NYXTOOLS_DEBUG) {
    case 1: NyxMsg(buffer);
    case 2: NyxMsgAdmin(buffer);
  }
#endif
}

stock void NyxAct(int client, const char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  char prefix[64];
  FormatEx(prefix, sizeof(prefix), "[%s] ", NYXTOOLS_TAG);

  ShowActivity2(client, prefix, "%s", buffer);
}

stock void SayText2(int client, int from, const char[] msg) {
  char buffer[256];
  Format(buffer, sizeof(buffer), "\x01%s", msg);

  Handle hBf;
  hBf = StartMessageOne("SayText2", client);
  if (hBf != null) {
    BfWriteByte(hBf, from);
    BfWriteByte(hBf, 0);
    BfWriteString(hBf, msg);
    EndMessage();
  }
}
