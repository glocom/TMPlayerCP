enum GameState {
    NotRunning,
    Running,
    Error,
}

namespace State {
    GameState currState = GameState::NotRunning;

    int clubId;
    int roomId;

    string status;

    bool get_IsNotRunning() { return currState == GameState::NotRunning; }
    bool get_IsRunning() { return currState == GameState::Running; }
    bool get_IsError() { return currState == GameState::Error; }

    void BeginGame() {
        if(currState == GameState::NotRunning) {
            clubId = S_ClubID;
            roomId = S_RoomID;
            bool inServer = BRM::IsInAServer(GetApp());
            if (inServer) {
                bool correctRoom = false;
                auto si = BRM::GetCurrentServerInfo(GetApp(), false);
                
                //Show Players CPs whenever we're on a map
                if(clubId <= 0 && roomId <= 0) {
                    correctRoom = true;
                }

                //Show Players CPs if we're in a specific club
                else if(roomId <= 0) {
                    correctRoom = si !is null && si.clubId == int(clubId);
                }
                //Show Players CPs if we're in a specific room in a specific club
                else {
                    correctRoom = si !is null && si.clubId == int(S_ClubID) && si.roomId == int(S_RoomID);
                }                

                if (correctRoom) {
                    currState = GameState::Running;
                } 
            }
        }
    }

    // should be called once per frame when necessary
    void CheckStillInServer() {
#if DEV
        return;
#endif
        if (!_IsStillInServer()) {
            currState = GameState::NotRunning;
        }
    }

    bool _IsStillInServer() {
        auto app = GetApp();
        if (!BRM::IsInAServer(app)) return false;
        if (app.PlaygroundScript !is null) return false;
        if (app.Editor !is null) return false;
        auto si = BRM::GetCurrentServerInfo(app, false);
        if (si is null) return false;
        
        clubId = S_ClubID;
        roomId = S_RoomID;
        //Show Players CPs whenever we're on a map
        if(clubId <= 0 && roomId <= 0) {
            return true;
        }
        //Show Players CPs if we're in a specific club
        else if(roomId <= 0) {
            return int(clubId) == si.clubId;
        }
        //Show Players CPs if we're in a specific room in a specific club
        else {
            return int(clubId) == si.clubId && int(roomId) == si.roomId;
        }   
        
    }
    
    void HardReset() {
        currState = GameState::NotRunning;
    }
}