package manage.modules.main
{
	import org.lcf.IContainer;
	
	import spark.components.Button;
	import spark.components.TextInput;

	import spark.components.supportClasses.SkinnableComponent;
	/**
	 * 个人信息设定
	 */ 
	public class MySettings extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var oldPass:TextInput;
		
		[SkinPart(required="true")]
		public var newPass:TextInput;
		
		[SkinPart(required="true")]
		public var newPass2:TextInput;
		
		[SkinPart(required="true")]
		public var name:TextInput;
		
		[SkinPart(required="true")]
		public var mobile:TextInput;
		
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		
		private var container:IContainer;
		
		public function MySettings(c:IContainer)
		{
			super();
			this.container = c;
		}
	}
}