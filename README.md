# Currency
A simple iOS currency conversion app written in Swift, using the Fixer.io API (http://fixer.io)

Features
- Simple layout with labels, text fields, picker view, buttons
- Functionality to convert currencies via the Fixer.io API
- Picker view to change the base currency to allow the user to see the conversion rates of their chosen currency
- Launch screen with simple images to make it seem like it's loading/doing something while it launches
- Spinner to indicate that the app is fetching data online from Fixer
- Disabled input while the app is fetching data online, essentially freezing it
- Updated Date and Time at the top of the app view to indicate when the Fixer conversion rates were last updated
- Refresh button to update Date and Time and convert current input in the text field
