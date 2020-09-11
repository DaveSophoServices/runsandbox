use reqwest::StatusCode;

fn main() {
    login("david@thousandpines.com", "RqqQ28cxdc5D5uhvZYo2");

			
	    
    
}

fn print_type_of<T>(_: &T) {
    println!("{}", std::any::type_name::<T>())
}

fn login(username:&str, password: &str) -> Result<&'static str,reqwest::Error>{
    let params = [("UserName",username), ("Password",password), ("RememberMe", &"false".to_string())];

    let client = reqwest::blocking::Client::new();
    let resp = client
	.post("https://go.runsandbox.com/Account/LogOn?ReturnUrl=/")
	.form(&params)
	.send()?;

    // print_type_of(&resp);

    // if we didn't unwrap with ? earlier, we could handle it as follows:
    // match resp {
    // 	Ok(resp) => println!("no error"),
    // 	Err(resp) => return,
    // }
    
    match resp.status() {
    	StatusCode::OK => println!("success"),
    	s => println!("received response status: {:?}", s),
    };

    return Ok("");
}
