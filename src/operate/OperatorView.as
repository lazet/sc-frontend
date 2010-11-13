package operate
{
	import flash.events.MouseEvent;
	
	import manage.ManagerView;
	import manage.MySettings;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.lcf.AbstractInnerModule;
	import org.lcf.Constants;
	import org.lcf.EventListenerModel;
	import org.lcf.IComponent;
	import org.lcf.IContainer;
	import org.lcf.IModuleManager;
	import org.lcf.Overlay;
	import org.lcf.util.GeneralBundleEvent;
	import org.lcf.util.ModuleEvent;
	
	import rpc.RpcEvent;
	import rpc.RpcService;
	
	import sign.SignInfo;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.PopUpAnchor;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	import util.Consts;
	import util.EventTypeDefine;
	import util.ObjectNameDefine;
	import util.RemoteDate;
	
	
	public class OperatorView extends SkinnableComponent implements IComponent
	{
		include "../util/ScUtil.as";
		[SkinPart(required="true")]
		public var unitName:Label;
		[SkinPart(required="true")]
		public var loginName:LinkButton;
		[SkinPart(required="true")]
		public var exit:LinkButton;
		[SkinPart(required="true")]
		public var toolBar:ButtonBar;
		[SkinPart(required="true")]
		public var content:Overlay;
		[SkinPart(required="true")]
		public var switchView:DropDownList;
		[SkinPart(required="true")]
		public var currentTime:Label;
		
		public var mySettings:MySettings;
		
		protected var c:IContainer;
		
		public function set container(c:IContainer):void{
			this.c = c;
			this.init();
		}
		public function get preferEventListeners():Array
		{
			var productDefine:EventListenerModel = new EventListenerModel("productDefine.findAll",onProductDefineFindAll);
			var product:EventListenerModel = new EventListenerModel("product.findAll",onProductFindAll);
			var discount:EventListenerModel = new EventListenerModel("discount.findAll",onDiscountFindAll);
			var minute:EventListenerModel = new EventListenerModel(EventTypeDefine.TIME_MINUTE_EVENT,onMinute);
			return [productDefine,product,discount,minute ];
		}
		protected function onMinute(e:GeneralBundleEvent):void{
			if(this.currentTime != null)
				this.currentTime.text = "当前时间：" + (e.bundle as String).substr(0,16);
		}
		protected function onProductDefineFindAll(e:GeneralBundleEvent):void{
			this.c.put(ObjectNameDefine.OPERATE_PRODUCT_DEFINE,e.bundle);
		}
		protected function onProductFindAll(e:GeneralBundleEvent):void{
			this.c.put(ObjectNameDefine.OPERATE_PRODUCTS,e.bundle);
		}
		protected function onDiscountFindAll(e:GeneralBundleEvent):void{
			this.c.put(ObjectNameDefine.OPERATE_DISCOUNTS,e.bundle);
		}
		public function OperatorView()
		{
			super();
			this.percentWidth = 100;
			this.percentHeight = 100;
			this.setStyle("skinClass",OperatorViewSkin);
		}
		protected function init():void{
			//获取商品定义 
			var arg:Object = new Object();
			arg[Consts.COLLECTION] = "productDefine";
			arg[Consts.CONDITION] = "{}";
			arg[Consts.ORDER_BY] = "{\"order\":1}";
			this.c.dispatch(new RpcEvent("data/findAll",arg));
			//加载商品列表
			var parg:Object = new Object();
			parg[Consts.COLLECTION] = "product";
			parg[Consts.CONDITION] = "{}";
			parg[Consts.ORDER_BY] = "{\"创建时间\":-1}";
			this.c.dispatch(new RpcEvent("data/findAll",parg));
			//加载折扣列表
			var darg:Object = new Object();
			darg[Consts.COLLECTION] = "discount";
			var today:String = this.c.get(ObjectNameDefine.TODAY) as String;
			darg[Consts.CONDITION] = '{"起始日期":{"$lte":"' + today + '"},"结束日期":{"$gte":"' + today + '"}, "状态":"active"}';
			darg[Consts.ORDER_BY] = "{\"创建时间\":-1}";
			
			this.c.dispatch(new RpcEvent("data/findAll",darg));
		}
		protected function calculatePrice():Boolean{
			var products:Array = c.get(ObjectNameDefine.OPERATE_PRODUCTS) as Array;
			var discounts:Array = c.get(ObjectNameDefine.OPERATE_DISCOUNTS) as Array;
			if(products == null || discounts == null){
				return false;
			}
			
			var lastProductCollection:ArrayCollection = new ArrayCollection();
			for(var i:int = 0; i < products.length; i++){
				var p:* = products[i];
				var pn:String = p["商品名称"] as String;
				var cp:Number = Number(p["当前价格"]);
				var category:Array = p["品类"] as Array;
				var specPrice:Number = cp;
				//循环判断折扣，看是否适合本商品，如果适合，则计算特价，如果是最低的特价，则更新最低价
				for(var j:int = 0; i < discounts.length;j++){
					var d:* = discounts[j];
					var duration:String = d["促销时段"];
					if(duration == null || duration == ''){
						duration = '0-24';
					}
					//解析促销时段
					var discountDuration:Array= decodePeriod(duration);
					//获取当前时间
					var now:RemoteDate = this.c.get(ObjectNameDefine.NOW) as RemoteDate;
					var hour:int = int(now.getHour());
					//判断当前时间是否在优惠时段
					if(discountDuration[hour] != 1){
						continue;
					}
					if(d["类型"] == "商品特价"){
						if(d["商品名称"] == pn){
							if(specPrice > d["特价"]){
								specPrice = d["特价"];
							}
						}
					}
					else if(d["类型"] == "品类折扣"){
						if(exist(d["品类"],category)){
							if(specPrice > d["特价"]){
								specPrice = d["特价"];
							}
						}
					}
					else if(d["类型"] == "全场折扣"){
						if(specPrice > d["特价"]){
							specPrice = d["特价"];
						}
					}
				}
				p["specPrice"] = specPrice;
			}
			
			return true;
		}
		protected function onExitClicked(e:MouseEvent):void{
			Alert.show("确定要退出系统吗？","系统提示",Alert.OK | Alert.CANCEL,this,onExit);
		}
		protected function onExit(e:CloseEvent):void{
			if(e.detail == Alert.OK){
				var mm:IModuleManager = this.c.get(Constants.OVERLAY) as IModuleManager;
				mm.closeOther("signOn");
			}
		}
		protected function onSwitchView(e:IndexChangeEvent):void{
			
			if(this.switchView.selectedItem["id"] == ObjectNameDefine.MANAGER_VIEW){
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.MANAGER_VIEW,"信息中心",new ManagerView()));
			}
			this.switchView.selectedIndex = 0;
			e.preventDefault();
		}
		protected function onSwitchContent(e:IndexChangeEvent):void{
			var bb:ButtonBar = ButtonBar(e.target);
			this.content.open(bb.selectedItem.url,bb.selectedItem.name,bb.selectedItem.url);
		}
		protected function onMySettings(e:MouseEvent):void{
			if(this.mySettings == null){
				this.mySettings = new MySettings(this.c);
			}
			PopUpManager.addPopUp(this.mySettings,this,true);
			PopUpManager.centerPopUp(this.mySettings);
		}
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.unitName){
				this.unitName.text = (this.c.get(SignInfo.SIGN_INFO) as SignInfo).unitName;
			}
			else if (instance == this.loginName){
				this.loginName.label = (this.c.get(SignInfo.SIGN_INFO) as SignInfo).loginName;
				this.loginName.addEventListener(MouseEvent.CLICK,onMySettings);
			}
			else if (instance == this.exit){
				this.exit.addEventListener(MouseEvent.CLICK,onExitClicked);
			}
			else if (instance == this.toolBar){
				this.toolBar.requireSelection= true;
				this.toolBar.labelField = "name";
				this.toolBar.dataProvider = new ArrayCollection([{"url":"operate/consume/ConsumePage.swf","name":"下单"},{"url":"operate/consume/consumeHistory.swf","name":"历史订单"}]);
				this.toolBar.addEventListener(IndexChangeEvent.CHANGE,onSwitchContent);
			}
			else if (instance == this.switchView){
				this.switchView.requireSelection = true;
				this.switchView.labelField = "name";
				this.switchView.dataProvider = new ArrayCollection([{"id":ObjectNameDefine.OPERATOR_VIEW,"name":"前台交易"},{"id":ObjectNameDefine.MANAGER_VIEW,"name":"后台管理"}]);
				this.switchView.addEventListener(IndexChangeEvent.CHANGE,onSwitchView);
			}
			else if (instance == this.content){
				this.content.container.parentContainer = this.c;
				//加载RPC服务
				var info:SysInfo = c.get(SysInfo.SYSTEM_INFO) as SysInfo;
				var rpcClient:RpcService = new RpcService(info.remoteSiteUrl);
				this.content.container.put(RpcService.RPC_SERVICE, rpcClient);
				
				this.content.open("operate/modules/consume/ConsumePage.swf","下单","operate/modules/consume/ConsumePage.swf");
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if (instance == this.exit){
				this.exit.removeEventListener(MouseEvent.CLICK,onExitClicked);
			}
			else if (instance == this.toolBar){
				this.toolBar.removeEventListener(IndexChangeEvent.CHANGE,onSwitchContent);
			}
			else if (instance == this.switchView){
				this.switchView.removeEventListener(IndexChangeEvent.CHANGE,onSwitchView);
			}
			else if (instance == this.loginName){
				this.loginName.removeEventListener(MouseEvent.CLICK,onMySettings);
			}
		}
	}
}