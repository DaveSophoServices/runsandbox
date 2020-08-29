use reqwest::StatusCode;

fn main() {
    let params = [("UserName","david@thousandpines.com"), ("Password","RqqQ28cxdc5D5uhvZYo2"), ("RememberMe", "false")];
    let client = reqwest::blocking::Client::new();
    let resp = client
	.post("https://go.runsandbox.com/Account/LogOn?ReturnUrl=/")
	.form(&params)
	.send();

    match resp {
	Ok(resp) => println!("no error"),
	Err(resp) => return,
    }
	    
    // match resp.status() {
    // 	StatusCode::OK => println!("success"),
    // 	s => println!("received response status: {:?}", s),
    // };
    
}
