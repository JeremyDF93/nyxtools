#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - Entity",
  author = "JeremyDF93",
  description = "",
  version = "1.0",
  url = "https://praisethemoon.com/"
};

/***
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public void OnPluginStart() {
  LoadTranslations("common.phrases");

  RegAdminCmd("nyx_entprop_class", ConCmd_EntPropClass, ADMFLAG_ROOT, "nyx_entprop_class <classname> <prop> [value]");
  RegAdminCmd("nyx_entfire_class", ConCmd_EntFireClass, ADMFLAG_ROOT, "nyx_entfire_class <classname> <input> [value]");
  RegAdminCmd("nyx_entprop_aim", ConCmd_EntPropAim, ADMFLAG_ROOT, "nyx_entprop_aim <prop> [value]");
  RegAdminCmd("nyx_entfire_aim", ConCmd_EntFireAim, ADMFLAG_ROOT, "nyx_entfire_aim <input> [value]");
  RegAdminCmd("nyx_entprop_player", ConCmd_EntPropPlayer, ADMFLAG_ROOT, "nyx_entprop_player <#userid|name> <prop> [value]");
  RegAdminCmd("nyx_entfire_player", ConCmd_EntFirePlayer, ADMFLAG_ROOT, "nyx_entprop_player <#userid|name> <input> [value]");
  RegAdminCmd("nyx_entprop_weapon", ConCmd_EntPropWeapon, ADMFLAG_ROOT, "nyx_entprop_weapon <#userid|name> <slot> <prop> [value]");
}

/***
 *       ______                                          __    
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  
 *                                                             
 */

public Action ConCmd_EntPropClass(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_entprop_class <classname> <prop> [value]");
    return Plugin_Handled;
  }

  char classname[32], prop[32], value[32];
  GetCmdArg(1, classname, sizeof(classname));
  GetCmdArg(2, prop, sizeof(prop));
  GetCmdArg(3, value, sizeof(value));

  int ent = -1;
  while ((ent = FindEntityByClassname(ent, classname)) != -1) {
    if (args == 3) {
      WriteEntProp(ent, prop, client, value);
    } else {
      ReadEntProp(ent, prop, client);
    }
  }

  return Plugin_Handled;
}

public Action ConCmd_EntFireClass(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_entfire_class <classname> <input> [value]");
    return Plugin_Handled;
  }

  char buffer[256], classname[64], input[128], value[128];
  GetCmdArgString(buffer, sizeof(buffer));
  TrimString(buffer);

  int len1 = BreakString(buffer, classname, sizeof(classname));
  int len2 = BreakString(buffer[len1], input, sizeof(input));
  strcopy(value, sizeof(value), buffer[len1 + len2]);
  StripQuotes(value);

  int ent = -1;
  while ((ent = FindEntityByClassname(ent, classname)) != -1) {
    if (args > 2) {
      SetVariantString(value);
    }
    AcceptEntityInput(ent, input);
  }

  LogAction(client, -1, "\"%L\" ran ent fire \"%s\" [\"%s\"] on all \"%s\"", client, input, value, classname);
  NyxAct(client, "Ran ent fire %s [%s] on all %s", input, value, classname);

  return Plugin_Handled;
}

public Action ConCmd_EntPropAim(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_entprop_aim <prop> [value]");
    return Plugin_Handled;
  }

  char prop[32], value[32];
  GetCmdArg(1, prop, sizeof(prop));
  GetCmdArg(2, value, sizeof(value));

  int ent = GetClientAimTargetEx(client);
  if (ent > 0) {
    if (args == 2) {
      WriteEntProp(ent, prop, client, value);
    } else {
      ReadEntProp(ent, prop, client);
    }
  } else {
    NyxMsgReply(client, "No aim target found.");
  }

  return Plugin_Handled;
}

public Action ConCmd_EntFireAim(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_entfire_aim <input> [value]");
    return Plugin_Handled;
  }

  char buffer[256], input[128], value[128];
  GetCmdArgString(buffer, sizeof(buffer));
  TrimString(buffer);

  int len = BreakString(buffer, input, sizeof(input));
  strcopy(value, sizeof(value), buffer[len]);
  StripQuotes(value);

  int ent = GetClientAimTargetEx(client);
  if (ent > 0) {
    if (args > 1) {
      SetVariantString(value);
    }
    AcceptEntityInput(ent, input);

    char classname[32];
    GetEntityClassname(ent, classname, sizeof(classname));

    LogAction(client, -1, "\"%L\" ran ent fire \"%s\" \"%s\" on \"%s\"", client, input, value, classname);
    NyxAct(client, "Ran ent fire %s [%s] on %s", input, value, classname);
  } else {
    NyxMsgReply(client, "No aim target found.");
  }

  return Plugin_Handled;
}

public Action ConCmd_EntPropPlayer(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_entprop_player <$userid|name> <prop> [value]");
    return Plugin_Handled;
  }

  char target[32], prop[32], value[32];
  GetCmdArg(1, target, sizeof(target));
  GetCmdArg(2, prop, sizeof(prop));
  GetCmdArg(3, value, sizeof(value));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    if (args == 3) {
      WriteEntProp(target_list[i], prop, client, value);
    } else {
      ReadEntProp(target_list[i], prop, client);
    }
  }

  return Plugin_Handled;
}

public Action ConCmd_EntFirePlayer(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_entfire_player <$userid|name> <input> [value]");
    return Plugin_Handled;
  }

  char buffer[256], target[64], input[128], value[128];
  GetCmdArgString(buffer, sizeof(buffer));
  TrimString(buffer);

  int len1 = BreakString(buffer, target, sizeof(target));
  int len2 = BreakString(buffer[len1], input, sizeof(input));
  strcopy(value, sizeof(value), buffer[len1 + len2]);
  StripQuotes(value);

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    if (args > 2) {
      SetVariantString(value);
    }
    AcceptEntityInput(target_list[i], input);
    LogAction(client, -1, "\"%L\" ran ent fire \"%s\" \"%s\" on \"%L\"", client, input, value, target_list[i]);
  }

  NyxAct(client, "Ran ent fire %s [%s] on %s", input, value, target_name);
  return Plugin_Handled;
}

public Action ConCmd_EntPropWeapon(int client, int args) {
  if (args < 3) {
    NyxMsgReply(client, "Usage: nyx_entprop_weapon <$userid|name> <slot> <prop> [value]");
    return Plugin_Handled;
  }

  char target[32], prop[32], value[32];
  GetCmdArg(1, target, sizeof(target));
  int slot = GetCmdIntEx(2, 0, 5, 0);
  GetCmdArg(3, prop, sizeof(prop));
  GetCmdArg(4, value, sizeof(value));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    int weapon = GetPlayerWeaponSlot(target_list[i], slot);
    if (weapon != -1) {
      if (args == 4) {
        WriteEntProp(weapon, prop, target_list[i], value);
      } else {
        ReadEntProp(weapon, prop, target_list[i]);
      }
    }
  }

  return Plugin_Handled;
}

/***
 *        ______                 __  _                 
 *       / ____/_  ______  _____/ /_(_)___  ____  _____
 *      / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 *     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
 *    /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/  
 *                                                     
 */

int GetEntDataOffs(int entity, const char[] prop, PropFieldType &type) {
  int offset = -1;
  char classname[64];

  if (GetEntityNetClass(entity, classname, sizeof(classname))) {
    offset = FindSendPropInfo(classname, prop, type);
  }

  if (offset < 1) {
    offset = FindDataMapInfo(entity, prop, type);
  }

  return offset;
}

void GetEntityName(int entity, char[] buffer, int maxlength) {
  if (entity <= 0 || entity > MaxClients) {
    GetEntityClassname(entity, buffer, maxlength);
  } else {
    GetClientName(entity, buffer, maxlength);
  }
}

void WriteEntProp(int entity, const char[] prop, int client, const char[] value) {
  char name[64];
  GetEntityName(entity, name, sizeof(name));

  PropFieldType type;
  int offset = GetEntDataOffs(entity, prop, type);

  if (offset < 1) {
    NyxMsgReply(client, "Prop '%s' not found on entity [%i:%s]", prop, entity, name);
    return;
  }

  switch (type) {
    case PropField_String: {
      SetEntDataString(entity, offset, value, strlen(value), true);
    }
    case PropField_String_T: {
      NyxMsgReply(client, "'%s' is read only!", prop);
    }
    case PropField_Vector: {
      float vec[3];
      StringToVector(value, vec);
      SetEntDataVector(entity, offset, vec);
    }
    case PropField_Float: {
      SetEntDataFloat(entity, offset, StringToFloat(value), true);
    }
    case PropField_Entity: {
      SetEntDataEnt2(entity, offset, StringToInt(value), true);
    }
    default: {
      SetEntData(entity, offset, StringToInt(value), 4, true);
    }
  }

  LogAction(client, -1, "\"%L\" set \"%s\" to \"%s\" on \"%s\"", client, prop, value, name);
  NyxAct(client, "Set '%s' to '%s' on '%s'", prop, value, name);
}

void ReadEntProp(int entity, const char[] prop, int client) {
  char name[64];
  GetEntityName(entity, name, sizeof(name));

  PropFieldType type;
  int offset = GetEntDataOffs(entity, prop, type);

  if (offset < 1) {
    NyxMsgReply(client, "Prop '%s' not found on entity [%i:%s]", prop, entity, name);
    return;
  }

  switch (type) {
    case PropField_String, PropField_String_T: {
      char str[256];
      GetEntDataString(entity, offset, str, sizeof(str));
      NyxMsgReply(client, "'%s' equals (String %s) on entity [%i:%s]", prop, str, entity, name);
    }
    case PropField_Vector: {
      float vec[3];
      GetEntDataVector(entity, offset, vec);
      NyxMsgReply(client, "'%s' equals (Vector %f, %f, %f) on entity [%i:%s]", prop, vec[0], vec[1], vec[2], entity, name);
    }
    case PropField_Float: {
      float value = GetEntDataFloat(entity, offset);
      NyxMsgReply(client, "'%s' equals (Float %f) on entity [%i:%s]", prop, value, entity, name);
    }
    case PropField_Entity: {
      int ent = GetEntDataEnt2(entity, offset);
      char name2[64]; GetEntityName(entity, name2, sizeof(name2));
      NyxMsgReply(client, "'%s' equals (Entity %i:%s) on entity [%i:%s]", prop, ent, name2, entity, name);
    }
    default: {
      int value = GetEntData(entity, offset);
      NyxMsgReply(client, "'%s' equals (Int %i) on entity [%i:%s]", prop, value, entity, name);
    }
  }
}
