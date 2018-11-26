import com.GameInterface.DistributedValue;
import com.GameInterface.Quest;
import com.GameInterface.QuestsBase;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

class com.fox.LairCooldowns {
	private var LairMissions:Object;
	private var CooldownOpened:DistributedValue;
	public static function main(swfRoot:MovieClip):Void {
		var mod = new LairCooldowns(swfRoot);
		swfRoot.onLoad = function() {mod.OnLoad()};
		swfRoot.onUnload = function() {mod.onUnload()};
	}

	public function LairCooldowns() {
		LairMissions = new Object();
		LairMissions["3434"] =  "Kingsmouth";
		LairMissions["3445"] =  "Kingsmouth";
		LairMissions["3422"] =  "Kingsmouth";

		LairMissions["3446"] =  "Savage Coast";
		LairMissions["3436"] =  "Savage Coast";
		LairMissions["3423"] =  "Savage Coast";

		LairMissions["3447"] =  "Blue Mountain";
		LairMissions["3424"] =  "Blue Mountain";
		LairMissions["3439"] =  "Blue Mountain";

		LairMissions["3448"] =  "Scorched Desert";
		LairMissions["3426"] =  "Scorched Desert";
		LairMissions["3428"] =  "Scorched Desert";

		LairMissions["3449"] =  "City of the Sun God";
		LairMissions["3425"] =  "City of the Sun God";
		LairMissions["3429"] =  "City of the Sun God";

		LairMissions["3413"] =  "Besieged Farmlands";
		LairMissions["3412"] =  "Besieged Farmlands";
		LairMissions["3411"] =  "Besieged Farmlands";

		LairMissions["3415"] =  "Shadowy Forest";
		LairMissions["3416"] =  "Shadowy Forest";
		LairMissions["3421"] =  "Shadowy Forest";

		LairMissions["3418"] =  "Carpathian Fangs";
		LairMissions["3419"] =  "Carpathian Fangs";
		LairMissions["3414"] =  "Carpathian Fangs";

		LairMissions["4056"] =  "Kaidan";
		LairMissions["4054"] =  "Kaidan";
		LairMissions["4064"] =  "Kaidan";
		CooldownOpened = DistributedValue.Create("lockoutTimers_window");
	}

	public function OnLoad() {
		CooldownOpened.SignalChanged.Connect(AddElements, this);
		AddElements();
	}

	public function onUnload():Void {
		CooldownOpened.SignalChanged.Disconnect(AddElements, this);
	}

	private function AddElements() {
		if (CooldownOpened.GetValue()) {
			if (_root.lockouttimers.m_Window.m_Content.m_RaidsHeader && _root.lockouttimers.m_Window.m_Content.m_EliteRaid) {
				var LairsHeader:TextField = _root.lockouttimers.m_Window.m_Content.m_RaidsHeader;
				LairsHeader.text = LairsHeader.text +" & Lairs";
				setTimeout(Delegate.create(this, PopulateLairs), 50);
			} else {
				setTimeout(Delegate.create(this, AddElements), 50);
			}
		}
	}

	private function IsLairMission(id:Number) {
		return LairMissions[string(id)];
	}

	private function CalculateTimeString(ExpireTime):String {
		var currentTime = new Date();
		currentTime = currentTime.getTime();
		var timeLeft = (ExpireTime*1000 - currentTime)/1000;

		var totalMinutes = timeLeft/60;
		var hours = totalMinutes/60;
		var hoursString = String(Math.floor(hours));
		if (hoursString.length == 1) { hoursString = "0" + hoursString; }
		var minutes = totalMinutes%60;
		var minutesString = String(Math.floor(minutes));
		if (minutesString.length == 1) { minutesString = "0" + minutesString; }
		return LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "TimeFormatHoursShort"), hoursString) + " " + LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "TimeFormatMinutesShort"), minutesString);
	}

	private function PopulateLairs() {
		var QuestsOnCooldown = QuestsBase.GetAllQuestsOnCooldown();
		var m_DA:MovieClip = _root.lockouttimers.m_Window.m_Content.m_DarkAgartha;
		var startY = m_DA._y + 20;
		var AlreadyAdded:Object = new Object();
		var OriginalSize = _root.lockouttimers.m_Window.m_Content._height;
		for (var id in QuestsOnCooldown) {
			var m_Quest:Quest = QuestsOnCooldown[id];
			var m_Name = IsLairMission(m_Quest.m_ID);
			if (m_Name && !AlreadyAdded[m_Name]) {
				var m_CopyClip:MovieClip = m_DA.duplicateMovieClip("m_"+m_Name, _root.lockouttimers.m_Window.m_Content.getNextHighestDepth());
				m_CopyClip.m_Character.deleteMovieClip();
				m_CopyClip.m_Name.text = m_Name;
				m_CopyClip._y = startY;
				startY += 20;
				m_CopyClip.m_Lockout.text = CalculateTimeString(m_Quest.m_CooldownExpireTime);
				AlreadyAdded[m_Name] = true;
			}
		}
		var newSize = _root.lockouttimers.m_Window.m_Content._height;
		_root.lockouttimers.m_Window.m_Background._height += newSize-OriginalSize;
		delete AlreadyAdded;
	}
}