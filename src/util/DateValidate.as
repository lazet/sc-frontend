package util
{
	import mx.validators.Validator;
	import mx.validators.ValidationResult;
	
	public class DateValidate extends Validator
	{
		public function DateValidate()
		{
			super();
		}
		public var minDate:String;
		public var maxDate:String;
		
		
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if(minDate != null && value != ""){
				if(minDate > value){
					results.push(new ValidationResult(true, null, "dateError","不能小于" + minDate));
				}
			}
			
			if(maxDate != null && value != ""){
				if(maxDate < value){
					results.push(new ValidationResult(true, null, "dateError","不能大于" + maxDate ));
				}
			}
			return results;
		}
	}
}