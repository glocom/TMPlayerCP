bool UserHasPermissions = false;

#if DEPENDENCY_MLFEEDRACEDATA || DEV
bool HaveDeps = true;
#else
bool HaveDeps = false;
#endif

int nvgFont = 0;
int MainWindowFlags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse;

const string PluginIcon = Icons::Kenney::Flag;
const string MenuTitle = PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;

// show the window immediately upon installation
[Setting hidden]
bool ShowWindow = true;

GameInterface@ gameInterface = GameInterface();

void Main() {
    UserHasPermissions = Permissions::PlayPublicClubRoom();
    nvgFont = nvg::LoadFont("DroidSans-Bold.ttf", true, true);
    // nvgFont = nvg::LoadFont("fonts/Montserrat-SemiBoldItalic.ttf", true, true);

    yield();
    if (Time::Now < 60000)
        sleep(1000);
}

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

void Render() {
    if (!UI::IsOverlayShown() && !S_ShowIfOverlayHidden) return;
    if (!UI::IsGameUIVisible() && !S_ShowIfUIHidden) return;

    if (!ShowWindow) return;
    
    State::BeginGame();
    if(!State::IsRunning) return;

    vec2 size = vec2(450, 300);
    vec2 wpos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    UI::SetNextWindowPos(int(wpos.x), int(wpos.y), UI::Cond::FirstUseEver);
    PushFontSize();
    UI::PushStyleColor(UI::Col::FrameBg, vec4(.2, .2, .2, .5));
    if (UI::Begin(MenuTitle, ShowWindow, MainWindowFlags)) {
        float minWidth = State::IsRunning ? 170 : 350;
        auto pos = UI::GetCursorPos();
        UI::Dummy(vec2(minWidth, 0));
        UI::SetCursorPos(pos);
        if (!HaveDeps || !UserHasPermissions) {
            UI::TextWrapped("You need club access and/or install Better Room Manager. (One of these checks failed.)");
        } else {
            gameInterface.RenderMain();
        }
    }
    UI::End();
    UI::PopStyleColor();
    PopFontSize();
}

void PushFontSize() {
    if (S_FontSize == FontSize::S16_Bold) {
        UI::PushFont(subheadingFont);
    } else if (S_FontSize == FontSize::S20) {
        UI::PushFont(headingFont);
    } else if (S_FontSize == FontSize::S26) {
        UI::PushFont(titleFont);
    }
}

void PopFontSize() {
    if (S_FontSize > FontSize::S16) {
        UI::PopFont();
    }
}