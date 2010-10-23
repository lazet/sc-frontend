package util
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import spark.components.ComboBox;
	
	public class ProductCagegoryValidate extends Validator
	{
		public var pcInput:ComboBox;
		
		public var isNeed:Boolean;
		
		public var pcInputError:String;
		
		public function ProductCagegoryValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if(this.pcInput.textInput.text == "" && this.isNeed){
				results.push(new ValidationResult(true, null, "requiredError",this.requiredFieldError));
			}
			
			if(this.pcInput.textInput.text != ""){
				var pattern:RegExp = /^[\u4e00-\u9fa5\w\s]*$/;
				var isSuccess:Boolean = pattern.test(this.pcInput.textInput.text);
				if(!isSuccess){
					results.push(new ValidationResult(true, null, "inputError",this.pcInputError));
				}
			}
			return results;
			
		}
	}
}