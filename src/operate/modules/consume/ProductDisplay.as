package operate.modules.consume
{
	import flash.events.MouseEvent;
	
	import org.lcf.IContainer;
	import org.lcf.util.GeneralBundleEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.NumericStepper;
	import spark.components.supportClasses.SkinnableComponent;
	
	import util.EventTypeDefine;
	import util.PhotoDisplay;
	
	public class ProductDisplay extends SkinnableComponent
	{
		public function ProductDisplay(data:*,container:IContainer)
		{
			super();
			this.data = data;
			this.c = container;
			this.setStyle("skinClass",ProductDisplaySkin);
		}
		[Bindable]
		public  var data:*;
		
		protected var c:IContainer;
		
		[SkinPart(required="true")]
		public var img:PhotoDisplay;
		[SkinPart(required="true")]
		public var productName:Label;
		[SkinPart(required="true")]
		public var currentPrice:Label;
		[SkinPart(required="true")]
		public var specPrice:Label;
		[SkinPart(required="true")]
		public var ad:Label;
		[SkinPart(required="true")]
		public var num:NumericStepper;
		[SkinPart(required="true")]
		public var buyButton:Button;
		
		protected function onBuy(e:MouseEvent):void{
			this.c.dispatch(new GeneralBundleEvent( EventTypeDefine.CONSUME_BUY_PRODUCT_EVENT,this));
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.img){
				img.text = data["商品图片"];
			}
			else if(instance == this.productName){
				this.productName.text = data["商品名称"];
			}
			else if(instance == this.currentPrice){
				this.currentPrice.text = ((data["当前价格"]/100.00)).toFixed(2);
			}
			else if(instance == this.specPrice){
				this.specPrice.text = ((data["特价"])/100.00).toFixed(2);
			}
			else if(instance == this.buyButton){
				this.buyButton.addEventListener(MouseEvent.CLICK,onBuy);
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.buyButton){
				this.buyButton.removeEventListener(MouseEvent.CLICK,onBuy);
			}
		}
	}
}