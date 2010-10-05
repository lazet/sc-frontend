package 
{
	/**
	 * 系统信息
	 */ 
	public class SysInfo
	{
		static public var SYSTEM_INFO:String = "SYSTEM_INFO";
		private var _remoteSiteUrl:String;
		
		public function get remoteSiteUrl():String{
			return this._remoteSiteUrl;
		}
		public function SysInfo(remoteUrl:String)
		{
			this._remoteSiteUrl = remoteUrl;
		}
	}
}