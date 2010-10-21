package util
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import spark.components.ComboBox;
	
	public class ProductCagegoryValidate extends Validator
	{
		public var pcInput:ComboBox;
		
		public function ProductCagegoryValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = new Array();
			if(this.pcInput.textInput.text == "" && this.required){
				results.push(new ValidationResult(
					true, null, "requiredError",
					this.requiredFieldError));
			}
			return results;
			
		}
	}
}