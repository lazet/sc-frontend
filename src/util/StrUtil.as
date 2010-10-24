package util
{
	import mx.utils.StringUtil;
	public class StrUtil
	{
		static public function toStr(a:Array):String{
			if(a == null)return "";
			var r:String = "";
			for(var i:int = 0; i < a.length; i++){
				if(a[i] != null && a[i] != ""){
					r = r+ a[i];
				}
				r = r+ ' ';
			}
			return StringUtil.trim(r);
		}

	}
}