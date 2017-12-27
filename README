# ✨ STARGAZERS

Hi reviewer!

## PROJECT STRUCTURE

Each file in the app was documented with design decisions and explanations. For a 3000 feet view of the application structure you can refer to the following sections of this file.

### ARCHITECTURE

The architectural pattern I followed while developing this application is lightly based on the Coordinator pattern. TL;DR This pattern does not deviate very much from the standard Apple MVC architecture. It only complements it by helping its user unpack an app into separate modules, representing all different functionalities, while avoiding the typical pitfalls of iOS development, like the creation of overstuffed view controllers with strong dependencies between them. Each view controller acts as a simple view and delegates handling of user input to a separate controller object (coordinator). The controller is then responsible for applying business logic and route management. If you are interested, you can find out more about it with this [blog post](http://khanlou.com/2015/10/coordinators-redux/) or this [talk](https://vimeo.com/144116310).

#### CONTROLLERS
- `StargazersController` manages the overall functionality. It receives events from all view controllers and responds to them by triggering user interface updates and the appropriate API calls via `GitHubAPIClient`.

#### MODELS
- `User` and `Repository` are the basic entities that are handled by the app.
- `GitHubAPIClient` is a lightweight wrapper on the GitHub API endpoints needed by the app: [user search](https://developer.github.com/v3/search/#search-users),
repositories and [stargazers](https://developer.github.com/v3/activity/starring/#list-stargazers)

#### VIEWS
- `UserTableViewCell` is a vanilla `UITableViewCell` subclass configurable for display of a user.
- `RepositoryTableViewCell` is a `UITableViewCell` subclass configurable for display of a repository, it makes use of PINRemoteImage UIImageView extensions to display a user's avatar image.

#### VIEW CONTROLLERS
- `UsersViewController` displays a list of users and dispatches selection events;
- `RepositoriesViewController` displays a list of repositories content needed requests and selection events (only if the selected repository has any stargazer);
- `StargazersViewController` displays a list of stargazers.

#### SERVICES
- `Webservice` a type that simplifies the execution of network requests.
- `Paginator` a lightweight class that simplifies consumption of paginated APIs like the repositories and stargazers ones.
- `Throttler` and `Limiter` are two utility classes used to manage the execution and cancellation of multiple requests.

#### EXTENSIONS
- A set of reusable extensions of Foundation and UIKit types.

#### PROTOCOLS
- `URLSessionType` is a protocol used to enable dependency injection of a URLSession like fake object during tests.

## TESTS
I've added unit tests for the many of the components of the app. Mostly the ones that have logic within and comprise the basic building blocks of the app. Unfortunately there's no integration test or UI test to see for now. 😰

## DEPENDENCIES

I used Carthage for dependency management.

##### [PINREMOTEIMAGE](https://github.com/pinterest/PINRemoteImage)

Image downloading and caching is a rather complex task that can seriously impact the performance of an application if implemented poorly. This is the reason why I decided against using a simple custom solution and added this library as a dependency. It's a battle tested library on which a large company is heavily invested.

###### NOTE TO THE REVIEWER

If parts of the app seem rushed or imperfect, please excuse me. I had a really busy last working week and I worked on this app on the 24th, 25th and 26th of December (which was my birthday 🎂), overloaded with food and drinks. If you would like I can continue working on the app in the following days, when I'll have more time at my disposal.
