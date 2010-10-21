package util
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	
	public class SelectOneValidate extends Validator
	{
		public var soInput:DropDownList;
		
		public function SelectOneValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = new Array();
			if(this.soInput.selectedIndex == -1  && this.required){
				results.push(new ValidationResult(
					true, null, "requiredError",
					this.requiredFieldError));
			}
			return results;
			
		}
	}
}