# izziSession
If your projects require user authentication and token management—handling token validation, authentication state, and secure storage—izziSession simplifies the process. It automates token storage, expiration checks, and refreshes tokens when needed, not just on app launch but also during authorized requests, ensuring seamless authentication with less effort.

![Static Badge](https://img.shields.io/badge/Swit-6.0-orange) ![Static Badge](https://img.shields.io/badge/iOS-16.6%2B-white) ![Static Badge](https://img.shields.io/badge/Version%20-%201.0.0-skyblue) ![Static Badge](https://img.shields.io/badge/LICENSE-MIT-yellow) ![Static Badge](https://img.shields.io/badge/SPM-SUCCESS-green)

## Features 🚀
- Save Tokens in Keychain.
- Retrieve Tokens from Keychain.
- Delete Tokens from Keychain.
- Easily Verify Token Validity: Check if the token is still valid with a simple method.
- Default Token Models or Custom Codable Models.

---------

## Default Keys for Keychain 🔑
| Parameter        | Key                   
| :-------------- | :-------------------- |
| `accessTokenKey`  | `izzi.session.accessToken`|
| `refreshTokenKey` | `izzi.session.refreshToken`|

---------

## Configuration ⚙️
| Parameter              | Key                                      | Description                                    | Default Value                               |
| :--------------------- | :--------------------------------------- | :--------------------------------------------- | :------------------------------------------ |
| `apiEndpoint`          | `string`                                 | **Required**. API endpoint.                   | N/A                                        |
| `customRequestBuilder` | `((String) -> RequestModel)`             | **Optional**. A closure that builds a custom request model using the `refreshToken`. | `DefaultRefreshRequestModel`               |
| `tokenExtractor`       | `((ResponseModel) -> String)`            | **Required**. A closure that extracts the token (e.g., `accessToken`) from the API response. | `DefaultTokenResponseModel`                |

---------

## Usage Guide 📖

First, inject izziSessionManager into your project

```swift
final class MyProject {
  private let izziSession: IzziSessionManager  

  init(izziSession: IzziSessionManager = IzziSessionManager()) {
    self.izziSession = izziSession
  }
}
```
Then, save the returned tokens from the response in Keychain for future use

```swift
do {
    let response: MyResponseModel = // API call to log in the user  
    try izziSession.saveTokensToKeychain(accessToken: response.access, refreshToken: response.refresh)
} catch {
    print(error)
}
```
-------
### Check validity with default response and request models

After successfully logging in and securely saving the tokens, on the app’s next launch, we can check token validity in RouterManager (or anywhere else) to decide where to navigate the user.

You can do this with a single line of code:

```swift
let api = "https://test.com/check_token"

do {
    try await izziSession.verifyTokenValidity(apiEndpoint: api)
    
    // Navigate user to the main screen
} catch {
    print(error)
    
    // Navigate user to the login screen
}
```
With the code above, we check token validity using the default request and response models, which are structured as follows:

```swift
struct DefaultRequestModel: Codable {
  let refresh: String
}

struct DefaultRsponseModel: Codable {
  let access: String
}
```
If your API only sends and receives tokens, you can freely use these default models and simply call:  `izziSession.verifyTokenValidity(apiEndpoint: api)`

-------
### Check validity with custom response and request models
If your API requires additional information—such as a device ID or other parameters—along with the token, you need to send a custom request model and handle a custom response model.

```swift
struct CustomRequestModel: Codable {
  let refreshToken: String
  let clientId: String
}

struct CustomResponseModel: Codable {
  let accessToken: String
  let deviceId: String
  let appVersion: String
}

-------

let api = "https://test.com/check_token"

do {
    try await izziSession.verifyTokenValidity(
      apiEndpoint: api,
      customRequestBuilder: { refreshToken in
        CustomRequestModel(refreshToken: refreshToken, clientId: "client123") // Custom request model
      },
      tokenExtractor: { (response:CustomResponseModel) in // Custom response model
        response.accessToken
      }
    )
        
    // your code to forward user in main screen
} catch {
    print(error)

    // forward user in login screen
}
```
----------

## Delete Tokens from Keychain 🗑️
To log out a user, you must also delete the tokens stored in the keychain. Use the following izziSession function:

```swift
func logOut() {
  do {
    try izziSession.deleteTokensFromKeychain()
      
    // Your logout logic
  } catch {
    print("Error during logout: \(error)")
  }
}
```
-------
## 🟢 With the verifyTokenValidity function, it’s also possible to check token validity or obtain a new token during authorized API calls. 🔄 🟢


## Other Functions 🔧
Additionally, if needed, you can use the following functions:
```swift
try izziSession.getAccessToken() // Retrieve only the access token  
try izziSession.getRefreshToken() // Retrieve only the refresh token  
try izziSession.saveOnlyAccessToken(token: "testToken") // Save only the access token  
try izziSession.saveOnlyRefreshToken(token: "testToken") // Save only the refresh token  
```
----
## Installation via Swift Package Manager 🖥️
- Open your project.
- Go to File → Add Package Dependencies.
- Enter URL: https://github.com/Desp0o/izziSession.git
- Click Add Package.

## Contact 📬

- Email: tornike.despotashvili@gmail.com
- LinkedIn: https://www.linkedin.com/in/tornike-despotashvili-250150219/
- github: https://github.com/Desp0o


