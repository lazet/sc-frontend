package operate
{
	import mx.controls.Button;
	
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ProductDisplay extends SkinnableComponent
	{
		public function ProductDisplay()
		{
			super();
		}
		[SkinPart(required="true")]
		public var productName:Label;
		[SkinPart(required="true")]
		public var currentPrice:Label;
		[SkinPart(required="true")]
		public var specPrice:Label;
		[SkinPart(required="true")]
		public var activities:Label;
		[SkinPart(required="true")]
		public var buy:Button;
	}
}