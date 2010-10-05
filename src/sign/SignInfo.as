package sign
{
	/**
	 * 登录信息
	 */ 
	public class SignInfo
	{
		public static var SIGN_INFO:String = "SIGN_INFO";
		//登录用户名
		private var _loginName:String;
		//单位名称
		private var _unitName:String;
		//密码令牌，用于加密
		private var _token:String;
		
		public function SignInfo(unitName:String, loginName:String, token:String)
		{
			this._loginName = loginName;
			this._unitName  = unitName;
			this._token     = token;
		}
		
		public function get loginName():String{
			return this._loginName;
		}
		public function get unitName():String{
			return this._unitName;
		}
		public function get token():String{
			return this._token;
		}
	}
}