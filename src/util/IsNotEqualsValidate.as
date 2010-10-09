package util
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import spark.components.TextInput;
	
	public class IsNotEqualsValidate extends Validator
	{
		public var word:String;
		public var equalsError:String;
		public function IsNotEqualsValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if(this.source[this.property] == word){
				results.push(new ValidationResult(
					true, null, "equalsError",
					equalsError));
				return results;
			}
			else{
				return results;
			}
		}
	}
}