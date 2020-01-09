#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - Prop",
  author = NYXTOOLS_AUTHOR,
  description = "",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
};

/***
 *        ______
 *       / ____/___  __  ______ ___  _____
 *      / __/ / __ \/ / / / __ `__ \/ ___/
 *     / /___/ / / / /_/ / / / / / (__  )
 *    /_____/_/ /_/\__,_/_/ /_/ /_/____/
 *
 */

enum eProp {
  Prop_Ref,
  String:Prop_Model[PLATFORM_MAX_PATH],
  Float:Prop_Pos[3],
  Float:Prop_Angle[3],
  Float:Prop_Scale,
  bool:Prop_Physics,
  bool:Prop_NoCollide,
}

/***
 *       ________      __          __
 *      / ____/ /___  / /_  ____ _/ /____
 *     / / __/ / __ \/ __ \/ __ `/ / ___/
 *    / /_/ / / /_/ / /_/ / /_/ / (__  )
 *    \____/_/\____/_.___/\__,_/_/____/
 *
 */

ArrayList g_hProps;

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

  g_hProps = new ArrayList(view_as<int>(eProp));

  RegAdminCmd("nyx_prop", ConCmd_Prop, ADMFLAG_ROOT, "nyx_prop <model> [x y z] [pitch yaw roll] [scale] [physics] [nocollide]");
  RegAdminCmd("nyx_clearprops", ConCmd_ClearProps, ADMFLAG_ROOT);
  RegAdminCmd("nyx_regenprops", ConCmd_RegenProps, ADMFLAG_ROOT);
  RegAdminCmd("nyx_exportprops", ConCmd_ExportProps, ADMFLAG_ROOT);

  HookEvent("round_start", Event_RoundStart);
}

public void OnPluginEnd() {
  CloseHandle(g_hProps);
}

public void OnMapEnd() {
  g_hProps.Clear();
}

public void OnMapStart() {
  char map[PLATFORM_MAX_PATH];
  GetNextMap(map, sizeof(map));
  GetMapDisplayName(map, map, sizeof(map));

  char path[PLATFORM_MAX_PATH];
  Format(path, sizeof(path), "cfg/nyxtools/prop/%s.cfg", map);

  if (FileExists(path)) {
    ServerCommand("exec \"%s\"", path[4]);
  }
}

/***
 *        ______                 __
 *       / ____/   _____  ____  / /______
 *      / __/ | | / / _ \/ __ \/ __/ ___/
 *     / /___ | |/ /  __/ / / / /_(__  )
 *    /_____/ |___/\___/_/ /_/\__/____/
 *
 */

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
  RegenerateProps();

  return Plugin_Continue;
}

/***
 *       ______                                          __
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  )
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/
 *
 */

 public Action ConCmd_Prop(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_prop <model> [x y z] [pitch yaw roll] [scale] [physics] [nocollide]");
    return Plugin_Handled;
  }

  char model[PLATFORM_MAX_PATH];
  GetCmdArg(1, model, sizeof(model));
  if (strncmp(model, "models/", 7, false) != 0) {
    Format(model, sizeof(model), "models/%s", model);
  }
  if (strncmp(model, ".mdl", 4, false) != 0) {
    Format(model, sizeof(model), "%s.mdl", model);
  }

  if (!FileExists(model, true)) {
    NyxMsgReply(client, "Missing model '%s'", model);
    return Plugin_Handled;
  }

  float endpos[3], angles[3];
  if (IsValidClient(client)) {
    float xaxis[3]={ 1.0, 0.0, 0.0 }, yaxis[3], normal[3];
    GetClientAimPosEx(client, endpos, normal);

    GetVectorCrossProduct(normal, xaxis, yaxis);
    if (NormalizeVector(yaxis, yaxis) < 0.001) {
      float vec[3]={ 1.0, 0.0, 0.0 };
      CopyVectors(vec, xaxis);
      GetVectorCrossProduct(normal, xaxis, yaxis);
      NormalizeVector(yaxis, yaxis);
    }
    GetVectorCrossProduct(yaxis, normal, xaxis);
    NormalizeVector(xaxis, xaxis);

    MatrixToAngles(xaxis, yaxis, normal, angles);
  }

  GetCmdVector(2, endpos, endpos);
  GetCmdVector(3, angles, angles);
  /*
  endpos[0] = GetCmdFloat(2, endpos[0]);
  endpos[1] = GetCmdFloat(3, endpos[1]);
  endpos[2] = GetCmdFloat(4, endpos[2]);
  angles[0] = GetCmdFloat(5, angles[0]);
  angles[1] = GetCmdFloat(6, angles[1]);
  angles[2] = GetCmdFloat(7, angles[2]);
  */
  float scale = GetCmdFloat(4, 1.0);
  bool physics = GetCmdBool(5, false);
  bool nocollide = GetCmdBool(6, false);

  int prop;
  if (physics) {
    prop = CreateEntityByName("physics_prop");
  } else {
    prop = CreateEntityByName("prop_dynamic");
  }
  if (!IsModelPrecached(model)) PrecacheModel(model);
  SetEntityModel(prop, model);
  SetEntProp(prop, Prop_Data, "m_nSolidType", SOLID_VPHYSICS);
  SetEntPropFloat(prop, Prop_Data, "m_flModelScale", scale);
  TeleportEntity(prop, endpos, angles, NULL_VECTOR);
  DispatchSpawn(prop);
  NyxAct(client, "Spawned '%s'", model);

  if (nocollide) {
    AcceptEntityInput(prop, "DisableCollision");
  }

  any aProp[eProp];
  aProp[Prop_Ref] = EntIndexToEntRef(prop);
  strcopy(aProp[Prop_Model], sizeof(aProp[Prop_Model]), model);
  CopyVectors(endpos, aProp[Prop_Pos]);
  CopyVectors(angles, aProp[Prop_Angle]);
  aProp[Prop_Scale] = scale;
  aProp[Prop_Physics] = physics;
  aProp[Prop_NoCollide] = nocollide;
  g_hProps.PushArray(aProp);

  return Plugin_Handled;
}

public Action ConCmd_ClearProps(int client, int args) {
  int count = ClearProps();
  NyxAct(client, "Cleared %d props", count);
  return Plugin_Handled;
}

public Action ConCmd_RegenProps(int client, int args) {
  int count = RegenerateProps();
  NyxAct(client, "Regenerated %d props", count);
  return Plugin_Handled;
}

public Action ConCmd_ExportProps(int client, int args) {
  char map[PLATFORM_MAX_PATH];
  GetNextMap(map, sizeof(map));
  GetMapDisplayName(map, map, sizeof(map));

  char path[PLATFORM_MAX_PATH];
  Format(path, sizeof(path), "cfg/nyxtools/prop/%s.cfg", map);

  File file = OpenFile(path, "wt");
  if (file == null) {
    NyxMsgReply(client, "Error in %s: Directory not found or missing write permissions", path);
    return Plugin_Handled;
  }

  any aProp[eProp];
  for (int i = 0; i < g_hProps.Length; i++) {
    g_hProps.GetArray(i, aProp);

    int ent = EntRefToEntIndex(aProp[Prop_Ref]);
    if (IsValidEntity(ent)) {
      file.WriteLine("nyx_prop %s \"%f %f %f\" \"%f %f %f\" %f %d %d",
          aProp[Prop_Model],
          aProp[Prop_Pos][0], aProp[Prop_Pos][1], aProp[Prop_Pos][2],
          aProp[Prop_Angle][0], aProp[Prop_Angle][1], aProp[Prop_Angle][2],
          aProp[Prop_Scale],
          aProp[Prop_Physics],
          aProp[Prop_NoCollide]
      );
    }
  }

  FlushFile(file);
  file.Close();

  return Plugin_Handled;
}

/***
 *        __    _ __
 *       / /   (_) /_  _________ ________  __
 *      / /   / / __ \/ ___/ __ `/ ___/ / / /
 *     / /___/ / /_/ / /  / /_/ / /  / /_/ /
 *    /_____/_/_.___/_/   \__,_/_/   \__, /
 *                                  /____/
 */

stock int RegenerateProps() {
  ArrayList props = g_hProps.Clone();
  ClearProps();

  any aProp[eProp];
  for (int i = 0; i < props.Length; i++) {
    props.GetArray(i, aProp);

    int prop;
    if (aProp[Prop_Physics]) {
      prop = CreateEntityByName("physics_prop");
    } else {
      prop = CreateEntityByName("prop_dynamic");
    }
    if (!IsModelPrecached(aProp[Prop_Model])) PrecacheModel(aProp[Prop_Model]);
    SetEntityModel(prop, aProp[Prop_Model]);
    SetEntProp(prop, Prop_Send, "m_nSolidType", SOLID_VPHYSICS);
    SetEntPropFloat(prop, Prop_Send, "m_flModelScale", aProp[Prop_Scale]);
    TeleportEntity(prop, aProp[Prop_Pos], aProp[Prop_Angle], NULL_VECTOR);
    DispatchSpawn(prop);

    aProp[Prop_Ref] = EntIndexToEntRef(prop);

    if (aProp[Prop_NoCollide]) {
      AcceptEntityInput(prop, "DisableCollision");
    }

    g_hProps.PushArray(aProp);
  }

  CloseHandle(props);

  return g_hProps.Length;
}

stock int ClearProps() {
  int count;
  any aProp[eProp];

  for (int i = 0; i < g_hProps.Length; i++) {
    g_hProps.GetArray(i, aProp);

    int ent = EntRefToEntIndex(aProp[Prop_Ref]);
    if (IsValidEntity(ent)) {
      count++;
      AcceptEntityInput(ent, "Kill");
    }
  }

  g_hProps.Clear();

  return count;
}
