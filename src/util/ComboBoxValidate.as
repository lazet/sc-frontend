package util
{
	import mx.validators.Validator;
	import mx.validators.ValidationResult;
	
	import spark.components.ComboBox;
	
	public class ComboBoxValidate extends Validator
	{
		public function ComboBoxValidate()
		{
			super();
		}
		
		public var regError:String;
		
		public var reg:String;
		
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if((this.source as ComboBox).textInput.text == "" && this.required){
				results.push(new ValidationResult(true, null, "requiredError",this.requiredFieldError));
			}
			
			if((this.source as ComboBox).textInput.text != ""){
				var pattern:RegExp = new RegExp(reg);
				var isSuccess:Boolean = pattern.test((this.source as ComboBox).textInput.text);
				if(!isSuccess){
					results.push(new ValidationResult(true, null, "inputError",this.regError));
				}
			}
			return results;
			
		}
	}
}