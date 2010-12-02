package operate.modules.note
{
	import mx.collections.ArrayCollection;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class Receipt extends SkinnableComponent
	{
		public var number:int;
		[Bindable]
		public var content:Array;
		[Bindable]
		public var title:String;
		[Bindable]
		public var tail:String;		
		
		[SkinPart(required="true")]
		public var headerTitle:Label;
		[SkinPart(required="true")]
		public var bottomInfo:Label;
		[SkinPart(required="true")]
		public var contentDisplay:DataGroup;
		
		public function Receipt(title:String = '',contentInfo:Array = null, tail:String = '',number:int = 1)
		{
			super();
			this.number = number;
			this.title = title;
			this.tail = tail;
			this.content = contentInfo;
			this.setStyle("skinClass",ReceiptSkin);
		}
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.contentDisplay){
				this.contentDisplay.dataProvider = new ArrayCollection(this.content);
			}
			else if(instance == this.headerTitle){
				this.headerTitle.text = this.title;
				
			}
			else if(instance == this.bottomInfo){
				this.bottomInfo.text = this.tail;
			}
		}
	}
}