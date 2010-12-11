package sign
{
	import manage.ManagerView;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.events.ResizeEvent;
	
	import operate.OperatorView;
	
	import org.lcf.IContainer;
	import org.lcf.util.GeneralBundleEvent;
	import org.lcf.util.ModuleEvent;
	
	import spark.components.DataGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	import util.EventTypeDefine;
	
	public class Navigator extends SkinnableComponent
	{
		public function Navigator(container:IContainer,modules:Array)
		{
			super();
			this.modules = new ArrayCollection(modules);
			this.c = container;
			this.setStyle("skinClass",NavigatorSkin);
		}
		public var c:IContainer;
		
		[Bindable]
		public var modules:ArrayCollection;
		[SkinPart(required="true")]
		public var dg:DataGroup;
		
		public function selected(e:GeneralBundleEvent):void{
			//切换到管理页面
			if(util.ObjectNameDefine.MANAGER_VIEW == e.bundle["url"])
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.MANAGER_VIEW,"信息中心",new ManagerView()));
			else
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.OPERATOR_VIEW,"收银台",new OperatorView()));
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.dg){
				this.dg.dataProvider = modules;
				this.dg.itemRenderer = new ClassFactory(NavigatorItemRenderer);
				this.dg.addEventListener(EventTypeDefine.NAVIGATOR_MODULE_SELECTED,selected);
			}
		}
		
	}
}