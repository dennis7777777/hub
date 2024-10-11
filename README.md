using UnityEngine;
using Unity.Netcode;
using com.crenetic.Notruf2019.Game;
using com.crenetic.Notruf2019.AI;
using System;
using System.Collections;
using Logger = com.crenetic.N2019Plugins.Framework.Logger;

//----------------------------------------------------------------------------------------------------------------------------------------
// The actual game loop
//----------------------------------------------------------------------------------------------------------------------------------------
public class GameLoop : IGameLoopSP
{
    //------------------------------------------------------------------------------------------------------------------------------------
    public static string Description { get { return "Script.BFDesc"; } }
    public static int Order { get { return 1; } }

    //------------------------------------------------------------------------------------------------------------------------------------
    private static readonly Logger LOG = Logger.GetLogger(typeof(GameLoop));

    //------------------------------------------------------------------------------------------------------------------------------------
    // structure to define working shifts
    //------------------------------------------------------------------------------------------------------------------------------------
    struct ShiftSetup
    {
        public readonly int startHour;  // when does this shift start
        public readonly int length;     // how long does the shift run in hours
        public readonly int hoursOff;   // how many hours off duty?
       
        public ShiftSetup(int startHour, int length, int hoursOff) { this.startHour = startHour; this.length = length; this.hoursOff = hoursOff; }
    }

    // basic shift setup
    private static readonly ShiftSetup[] shiftSetup =
    {
        new ShiftSetup(8, 24, 24),      // 24 hour shift starting at 7 in the morning, 24 hours off
        new ShiftSetup(8, 24, 24),
        new ShiftSetup(8, 24, 24),
        new ShiftSetup(18, 24, 24),     // 24 hour shift starting at 18 in the evening, 24 hours off
        new ShiftSetup(18, 24, 24),
        new ShiftSetup(18, 24, 48),     // same as above about 48 hours off duty afterwards
    };

    //------------------------------------------------------------------------------------------------------------------------------------
    private readonly bool sandboxMode = false;

    private const float SITUATION_MIN_DELAY = 0.01f;     // min and max delay between missions in hours
    private const float SITUATION_MAX_DELAY = 0.2f;

    //------------------------------------------------------------------------------------------------------------------------------------
    private enum State
    {
        OffDuty,
        WaitingForSituation,
        FastForwardToSituation,
        SituationActive,
    }
    private State state = State.OffDuty;

    private int shiftCount = 0;         // total number of shifts so far
    private int iShift = 0;             // current index into ShiftSetup array
    private bool musterDone = false;
    private bool vehiclesDone = false;
    private DateTime shiftStart, shiftEnd;

    //------------------------------------------------------------------------------------------------------------------------------------
    public GameLoop()
    {
        Global.Game.SetTaggedGameObjects("GameModeMain", true);
        Global.Game.SetTaggedGameObjects("GameModeVolunteer", false);
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    public void SpawnUnits()
    {
        // ELW
        Global.Game.SpawnCar("ELW", "ELW", 1000, "ELW_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("ELW", "IncidentCmdr", "fireman_elw_commander", "Leader", "Einsatzleiter", "ELW_Troop", new Vector3(0, 0, 0));
        Global.Game.SpawnAgent("ELW", "Messenger", "fireman_elw_assistant", "Messenger", "Fuehrungsassistent", "ELW_Troop", new Vector3(1, 0, 0));

        // LF24
        Global.Game.SpawnCar("LF24", "LF24", 2000, "LF24_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("LF24", "SquadLeader", "fireman_lf24_leader", "Leader", "Gruppenfuehrer", "LF24_Leader", new Vector3(0, 0, 0));
        Global.Game.SpawnAgent("LF24", "ATLeader", "fireman_lf24_attacktroop_leader", "AttackLeader", "Angriffstruppfuehrer", "LF24_Troop", new Vector3(1, 0, 0));
        Global.Game.SpawnAgent("LF24", "WTLeader", "fireman_lf24_watertroop_leader", "DefaultAgentSetup", "Wassertruppfuehrer", "LF24_Troop", new Vector3(3, 0, 0));
        Global.Game.SpawnAgent("LF24", "ATTroop", "fireman_lf24_attacktroop", "AttackTroop", "Angriffstruppmann", "LF24_Troop", new Vector3(2, 0, 0));
        Global.Game.SpawnAgent("LF24", "WTTroop", "fireman_lf24_watertroop", "WaterTroop", "Wassertruppmann", "LF24_Troop", new Vector3(4, 0, 0));
        Global.Game.SpawnAgent("LF24", "LF24Engineer", "fireman_lf24_engineer", "Engineer", "Maschinist", "LF24_Troop", new Vector3(5, 0, 0));

        // TLF
        Global.Game.SpawnCar("TLF", "TLF", 3000, "TLF_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("TLF", "TLFLeader", "fireman_tlf_leader", "TLFAttackTroop", "Angriffstruppfuehrer", "TLF_Troop", new Vector3(1, 0, 0));
        Global.Game.SpawnAgent("TLF", "TLFEngineer", "fireman_tlf_engineer", "TLFEngineer", "Maschinist", "TLF_Troop", new Vector3(0, 0, 0));

        // KEF
        Global.Game.SpawnCar("KEF", "KEF", 4000, "KEF_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("KEF", "KEFLeader", "fireman_kef_leader", "KEFLeader", "Angriffstruppfuehrer", "KEF_Troop", new Vector3(1, 0, 0));
        Global.Game.SpawnAgent("KEF", "KEFEngineer", "fireman_kef_engineer", "KEFEngineer", "Maschinist", "KEF_Troop", new Vector3(0, 0, 0));

        // DLK
        Global.Game.SpawnCar("DLK", "DLK", 5000, "DLK_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("DLK", "DLKLeader", "fireman_dlk_leader", "DLKLeader", "Angriffstruppfuehrer", "DLK_Troop", new Vector3(1, 0, 0));
        Global.Game.SpawnAgent("DLK", "DLKEngineer", "fireman_dlk_engineer", "DLKEngineer", "Maschinist", "DLK_Troop", new Vector3(0, 0, 0));

        // RTW
        Global.Game.SpawnCar("RTW", "RTW", 6000, "RTW_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("RTW", "Paramedic", "fireman_rtw_officer", "Paramedic", "Notfallsanitaeter", "RTW_Troop", new Vector3(0, 0, 0));
        Global.Game.SpawnAgent("RTW", "RTWEngineer", "fireman_rtw_paramedic", "RTWEngineer", "Rettungssanitaeter", "RTW_Troop", new Vector3(1, 0, 0));

        // PKW
        Global.Game.SpawnCar("PKW", "PKW", 7000, "PKW_Spawn", Vector3.zero);

        // POL
        Global.Game.SpawnCar("POL", "POL", 8000, "POL_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("POL", "Policeman", "police_default", "Police", "Polizist", "POL_Troop", new Vector3(0, 0, 0));

        // NEF
        Global.Game.SpawnCar("NEF", "NEF", 9000, "NEF_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("NEF", "NEFLeader", "fireman_nef_leader", "NEFLeader", "Notarzt", "NEF_Troop", new Vector3(0, 0, 0));

        // NEF_OLD
        Global.Game.SpawnCar("NEF_OLD", "NEF_OLD", 9200, "NEF_OLD_Spawn", Vector3.zero);

        // OKW (Oldtimer-Kranwagen)
        Global.Game.SpawnCar("OKW", "OKW", 8900, "OKW_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("OKW", "OKWDriver", "fireman_okw_driver", "OKWDriver", "Maschinist", "OKW_Driver", new Vector3(0, 0, 0));

        // WLF
        Global.Game.SpawnCar("WLF", "WLF", 9500, "WLF_Spawn", Vector3.zero);
        Global.Game.SpawnAgent("WLF", "WLFLeader", "fireman_wlf_leader", "WLFLeader", "Truppfuehrer", "WLF_Troop", new Vector3(1, 0, 0));
        Global.Game.SpawnAgent("WLF", "WLFEngineer", "fireman_wlf_engineer", "WLFEngineer", "Maschinist", "WLF_Troop", new Vector3(0, 0, 0));

        Global.Game.SpawnLevelObject("AB01", "AB01_Spawn");
        Global.Game.SpawnLevelObject("AB02", "AB02_Spawn");
        Global.Game.SpawnLevelObject("AB10", "AB10_Spawn");
        Global.Game.SpawnLevelObject("AB13", "AB13_Spawn");
        Global.Game.SpawnLevelObject("AB15", "AB15_Spawn");
        Global.Game.SpawnLevelObject("AB16", "AB16_Spawn");
        Global.Game.SpawnLevelObject("AB17", "AB17_Spawn");
        Global.Game.SpawnLevelObject("AB19", "AB19_Spawn");
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    public IEnumerator Run()
    {
        MissionHelper.SetupDefaultMissions();

        iShift = 0;
        musterDone = false;
        vehiclesDone = false;
        
        //--------------------------------------------------------------------------------------------------------------------------------
        // determine current game time 
        DateTime now = DateTime.Now;
        // create starting day by using "today's" date but custom hour 
        shiftStart = new DateTime(now.Year, now.Month, now.Day, shiftSetup[iShift].startHour, 0, 0);
        // calculate shift end by adding desired hours
        shiftEnd = shiftStart.AddHours(shiftSetup[iShift].length);

        // let the game run until it reached the desired starting date
        yield return ChangeDay(shiftStart, false);

        Global.Enviroment.GameSpeed = 1.0f;

        if (sandboxMode)
        {
            if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("Game launched in SANDBOX mode.");
            yield break;
        }

        //--------------------------------------------------------------------------------------------------------------------------------
        for (; ; )
        {
            //----------------------------------------------------------------------------------------------------------------------------
            // shift starts here
            if (Logger.LogLevel >= Logger.Level.INFO) LOG.InfoFormat("Shift #{0} runs from {1} to {2}", shiftCount, shiftStart, shiftEnd);

            //----------------------------------------------------------------------------------------------------------------------------
            //check if player has general hints activated
            bool generalHintsActive = false;
            IWMFact wmGenerealHints = Global.AI.Memory.Find(FactType.Knowledge, new WMQuery("GeneralHints"));
            if (wmGenerealHints != null && wmGenerealHints.Get("GeneralHints", out bool hintsActive))
            {
                generalHintsActive = hintsActive;
            }
            //----------------------------------------------------------------------------------------------------------------------------
            // daily chores
            if (!musterDone)
            {
                Global.Game.DisableProgressSave = true;

                if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("Muster time!");
                WMQuery[] queryMuster = { new WMQuery("Muster") };
                Global.AI.Memory.Add(FactType.Task, queryMuster);
                do
                {
                    yield return WaitALittleWhile();
                }
                while (Global.AI.Memory.Find(FactType.Task, queryMuster) != null);
                musterDone = true;

                Global.Game.DisableProgressSave = false;
            }

            bool skipVehicleCheck = false;
            IWMFact wmVehicleCheck = Global.AI.Memory.Find(FactType.Knowledge, new WMQuery("VehicleCheck"));
            if (wmVehicleCheck != null && wmVehicleCheck.Get("VehicleCheck", out bool doCheck))
            {
                skipVehicleCheck = !doCheck;
            }

            if (!skipVehicleCheck && !vehiclesDone)
            {
                if (generalHintsActive)
                {
                    Global.Game.SetGeneralPopup("Tutorial.WaitForVehicleCheck");
                    Global.Game.SetGeneralHint("Tutorial.DoVehicleCheck");
                }

                Global.Game.DisableProgressSave = true;

                if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("Init vehicle check");
                foreach (var squad in Global.AI.Squads)
                {
                    if (squad.CanHandleGoal("ChangeForVehicleCheck"))
                    {
                        squad.RequestHandler.Create(null, "ChangeCheckspot", true);
                    }
                }

                if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("Wait for at least one squad to start the check");
                bool checkHasStarted = false;
                while (!checkHasStarted)
                {
                    foreach (var squad in Global.AI.Squads)
                    {
                        if (squad.Status == SquadStatus.OutOfDuty)
                        {
                            checkHasStarted = true;
                            break;
                        }
                    }
                    yield return new WaitForSeconds(5.0f);
                }

                if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("Waiting for all squads to return to the garage");
                bool squadsReturned = false;
                while (!squadsReturned)
                {
                    squadsReturned = true;
                    foreach (var squad in Global.AI.Squads)
                    {
                        if (squad.Status != SquadStatus.DutyHome || squad.RequestHandler.Exists("ChangeCheckspot"))
                        {
                            squadsReturned = false;
                            break;
                        }
                    }
                    if (squadsReturned)
                        break;

                    yield return new WaitForSeconds(10.0f);
                }
                vehiclesDone = true;

                Global.Game.DisableProgressSave = false;

                if (Logger.LogLevel >= Logger.Level.INFO) LOG.Info("All squads set to DutyHome");
            }

            //----------------------------------------------------------------------------------------------------------------------------
            // run until shift ends 
            while (!IsShiftOver(shiftEnd))
            {
                state = State.OffDuty;

                // get actual time
                now = new DateTime(Global.Enviroment.Time);

                // choose a random delay until next mission
                float delay = UnityEngine.Random.Range(SITUATION_MIN_DELAY, SITUATION_MAX_DELAY);
                DateTime nextSituation = now.AddHours(delay);
                if (Logger.LogLevel >= Logger.Level.INFO) LOG.InfoFormat("Now={0}, next situation={1}", now, nextSituation);


                // wait in idle loop until nextSituation timestamp is reached
                state = State.WaitingForSituation;

                if (generalHintsActive)
                {
                    Global.Game.SetGeneralPopup("Tutorial.WaitForMission");
                    //Global.Game.ShowPopup("Tutorial.WaitForMission");
                    Global.Game.SetGeneralHint("Menu.FurtherDetailHint_Station");
                }
                do
                {
                    yield return null;
                    now = new DateTime(Global.Enviroment.Time);

                    // check if we triggered the "fast-forward to next mission" interaction?
                    if (state == State.FastForwardToSituation)
                    {
                        Global.Enviroment.ChangeTo(nextSituation, false, false);
                        yield return new WaitWhile(() => Global.Enviroment.IsChangingDate);
                        break;
                    }
                }
                while (now < nextSituation);

                yield return WaitALittleWhile();

                // try to launch new situation and wait until it's done
                // don't launch a new situation if one is active (e.g. via console)
                if (Global.SituationController.IsSituationActive || Global.SituationController.StartRandomSituation())
                {
                    Global.Game.DisableProgressSave = true;

                    state = State.SituationActive;
                    Global.Game.SetGeneralPopup("Hint.FinishMission");
                    Global.Game.SetGeneralHint("Menu.FurtherDetailHint_Mission");
                    while (Global.SituationController.IsSituationActive)
                    {
                        yield return WaitALittleWhile();
                    }

                    Global.Game.DisableProgressSave = false;
                }
            }

            state = State.OffDuty;

            // setup next shift start and end 
            now = new DateTime(Global.Enviroment.Time);
            if (Logger.LogLevel >= Logger.Level.INFO) LOG.InfoFormat("Shift #{0} ends at {1}, desired end was {2}", shiftCount, now, shiftEnd);

            // check if we did some overtime, if so then just move the next shift one day forward
            shiftStart = shiftEnd.AddHours(shiftSetup[iShift].hoursOff);

            // choose next shift setup, start from the beginning if we reached the end of the array
            if (++iShift >= shiftSetup.Length)
                iShift = 0;

            // calculate new shift starting time
            shiftStart = new DateTime(shiftStart.Year, shiftStart.Month, shiftStart.Day, shiftSetup[iShift].startHour, 0, 0);
            while (shiftStart <= now)
            {
                shiftStart.AddDays(1);
            }

            shiftEnd = shiftStart.AddHours(shiftSetup[iShift].length);

            shiftCount++;

            Global.AI.Memory.Invalidate(FactType.Task, new WMQuery("Muster"));

            // change to next working day
            yield return ChangeDay(shiftStart, false);
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    private static IEnumerator WaitALittleWhile()
    {
        yield return new WaitForSeconds(5.0f);
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    public void OnInteract(IAgent agent, string name, bool start)
    {
        if (start && name.StartsWith("Resting"))
        {
            if (state == State.WaitingForSituation)
            {
                if (Logger.LogLevel >= Logger.Level.INFO) LOG.InfoFormat("{0} triggers fast-forward time with {1}", agent, name);
                state = State.FastForwardToSituation;
            }
            else if (sandboxMode && !Global.SituationController.IsSituationActive)
            {
                if (Logger.LogLevel >= Logger.Level.INFO) LOG.InfoFormat("{0} triggers auto-launch mission with {1}", agent, name);
                Global.SituationController.StartRandomSituation();
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    /// <summary>
    /// Sets a new date and waits until change is complete
    /// </summary>
    /// <param name="global"></param>
    /// <param name="time">desired target date + time</param>
    private IEnumerator ChangeDay(DateTime time, bool immediately)
    {
        Global.Enviroment.SetRandomWeather();
        //Global.Enviroment.SetWeather("Clear");

        Global.Enviroment.ChangeTo(time, immediately, true);
        yield return new WaitWhile(() => Global.Enviroment.IsChangingDate);
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    private bool IsShiftOver(DateTime time)
    {
        if (Global.SituationController.IsSituationActive)
            return false;

        if (Global.Enviroment.Time < time.Ticks)
            return false;

        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    public void SaveProgress(FastBufferWriter writer)
    {
        BytePacker.WriteValuePacked(writer, shiftCount);
        BytePacker.WriteValuePacked(writer, iShift);
        BytePacker.WriteValuePacked(writer, musterDone);
        BytePacker.WriteValuePacked(writer, vehiclesDone);
        BytePacker.WriteValuePacked(writer, shiftStart.Ticks);
        BytePacker.WriteValuePacked(writer, shiftEnd.Ticks);
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    public void LoadProgress(FastBufferReader reader)
    {
        ByteUnpacker.ReadValuePacked(reader, out shiftCount);
        ByteUnpacker.ReadValuePacked(reader, out iShift);
        ByteUnpacker.ReadValuePacked(reader, out musterDone);
        ByteUnpacker.ReadValuePacked(reader, out vehiclesDone);

        ByteUnpacker.ReadValuePacked(reader, out long startTicks);
        shiftStart = new DateTime(startTicks);

        ByteUnpacker.ReadValuePacked(reader, out long endTicks);
        shiftEnd = new DateTime(endTicks);
    }
}
