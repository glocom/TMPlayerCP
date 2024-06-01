class GameInterface {

    GameInterface() {
    }

    void RenderMain() {        
        State::CheckStillInServer();
        if (State::IsRunning) {
            RenderRunning();
        } else if (State::IsError) {
            RenderError();
        } else if (State::IsNotRunning) {
            RenderIsNotRunning();
        } else {
            UI::Text("\\$f80UNKNOWN STATE!");
        }
    }

    void RenderRunning() {
        UI::AlignTextToFramePadding();
        UI::SetNextItemWidth(200);

#if DEPENDENCY_MLFEEDRACEDATA

        auto rd = MLFeed::GetRaceData_V4();
        UI::ListClipper clip(rd.SortedPlayers_Race.Length);
        if (UI::BeginTable("player-curr-runs", 4, UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY)) {
            UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("cp", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("time", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("delta", UI::TableColumnFlags::WidthStretch);

            while (clip.Step()) {
                for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
                    auto p = cast<MLFeed::PlayerCpInfo_V4>(rd.SortedPlayers_Race[i]);
                    UI::PushID(i);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::Text(p.Name);
                    UI::TableNextColumn();
                    UI::Text(tostring(p.CpCount));
                    UI::TableNextColumn();
                    UI::Text(Time::Format(p.LastCpOrRespawnTime));

                    UI::PopID();
                }
            }

            UI::EndTable();
        }
#else
        // shouldn't show up, but w/e
        UI::Text("MLFeed required.");
#endif
    }

    void RenderError() {
        SubHeading("Error!");
        UI::TextWrapped(State::status);
        UI::Button("Todo retry");
        if (UI::Button("Reset Plugin")) {
            State::HardReset();
        }
    }

    void RenderIsNotRunning() {
        UI::Text("Initializing...");
    }
}