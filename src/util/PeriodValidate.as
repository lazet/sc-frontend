package util
{
	import mx.validators.StringValidator;
	import mx.validators.ValidationResult;
	
	public class PeriodValidate extends StringValidator
	{
		public var periodError:String;
		
		public function PeriodValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			
			var hours:Array = new Array();

			if(this.source.text != ""){
				var segments:Array = String(value).split(",");
				for(var i:int; i< segments.length;i ++ ){
					var seg:String = segments[i];
					if(seg == ""){
						results.push(new ValidationResult(true, null, "inputError",this.periodError));
						break;
					}
					var pair:Array = seg.split("-");
					if(pair.length !=2){
						results.push(new ValidationResult(true, null, "inputError",this.periodError));
						break;
					}
					try{
						var start:int = parseInt(pair[0]);
						var end:int = parseInt(pair[1]);
						if(isNaN(start) || isNaN(end) || start >= end || start < 0 || end > 24){
							results.push(new ValidationResult(true, null, "inputError",this.periodError));
							break;	
						}
						for(var j:int= start; j < end; j++){
							if(hours[j] == 1){
								results.push(new ValidationResult(true, null, "inputError",this.periodError));
								break;	
							}
							else{
								hours[j] = 1
							}
						}
					}catch(e:Error){
						results.push(new ValidationResult(true, null, "inputError",this.periodError));
					}
				}
			}
			return results;
			
		}
	}
}