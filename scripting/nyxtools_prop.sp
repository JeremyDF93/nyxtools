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
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public void OnPluginStart() {
  LoadTranslations("common.phrases");

  RegAdminCmd("nyx_prop", ConCmd_Prop, ADMFLAG_ROOT, "nyx_prop <model> [x y z] [pitch yaw roll] [scale] [nocollide]");
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
    NyxMsgReply(client, "Usage: nyx_prop <model> [x y z] [pitch yaw roll] [scale] [nocollide]");
    return Plugin_Handled;
  }

  char model[PLATFORM_MAX_PATH];
  GetCmdArg(1, model, sizeof(model));
  if (!FileExists(model, true)) {
    NyxMsgReply(client, "Missing model '%s'", model);
    return Plugin_Handled;
  }

  float aim[3];
  float fwd[3]={ 1.0, 0.0, 0.0 }, right[3], up[3];
  float normal[3];
  if (IsValidClient(client)) {
    GetClientAimPosEx(client, aim, normal);

    GetVectorCrossProduct(normal, fwd, right);
    if (NormalizeVector(right, right) < 0.001) {
      float init[3]={ 1.0, 0.0, 0.0 };
      CopyVectors(init, fwd);
      GetVectorCrossProduct(normal, fwd, right);
      NormalizeVector(right, right);
    }
    GetVectorCrossProduct(right, normal, fwd);
    NormalizeVector(fwd, fwd);



    float ang[3]; //GetClientEyeAngles(client, ang);
    //fwd[1] = ang[1];
    //GetAngleVectors(normal, fwd, right, up);
    //GetVectorAngles(up, ang);
    NyxMsgAll("normal %f %f %f", normal[0], normal[1], normal[2]);
    NyxMsgAll("ang %f %f %f", ang[0], ang[1], ang[2]);
    NyxMsgAll("fwd %f %f %f", fwd[0], fwd[1], fwd[2]);
    NyxMsgAll("right %f %f %f", right[0], right[1], right[2]);
    NyxMsgAll("up %f %f %f", up[0], up[1], up[2]);
  }

  float pos[3]; GetCmdVector(2, pos, aim);
  float ang[3]; GetCmdVector(3, ang, fwd);
  float scale = GetCmdFloat(4, 1.0);
  bool nocollide = GetCmdBool(5);

  if (!IsModelPrecached(model)) {
    PrecacheModel(model);
  }

  int prop = CreateEntityByName("prop_dynamic");
  SetEntityModel(prop, model);
  SetEntProp(prop, Prop_Send, "m_nSolidType", SOLID_VPHYSICS);
  SetEntPropFloat(prop, Prop_Send, "m_flModelScale", scale);
  TeleportEntity(prop, pos, ang, NULL_VECTOR);
  DispatchSpawn(prop);
  if (nocollide) {
    AcceptEntityInput(prop, "DisableCollision");
  }
  NyxAct(client, "Spawned '%s'", model);

  return Plugin_Handled;
}

stock bool GetClientAimPosEx(int client, float vec[3], float normal[3], int mask = MASK_ALL) {
  float origin[3], angles[3];
  GetClientEyePosition(client, origin);
  GetClientEyeAngles(client, angles);

  Handle trace = TR_TraceRayFilterEx(origin, angles, mask, RayType_Infinite, TraceEntityFilter_Players);
  if (TR_DidHit(trace)) {
    TR_GetEndPosition(vec, trace);
    TR_GetPlaneNormal(trace, normal);
    CloseHandle(trace);
    return true;
  }

  CloseHandle(trace);
  return false;
}
