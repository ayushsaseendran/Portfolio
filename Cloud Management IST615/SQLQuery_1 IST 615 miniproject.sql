-- Check and Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'OnlineRecipeSharingPlatform')
    CREATE DATABASE OnlineRecipeSharingPlatform;
GO

-- Use the Database
USE OnlineRecipeSharingPlatform;
GO
-- Dropping Constraints and Cleanup
-- Dropping Constraints
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_Recipes_Recipe_IngredientID')
    ALTER TABLE Recipes DROP CONSTRAINT fk_Recipes_Recipe_IngredientID;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_RecipeCuisines_RecipeCuisine_RecipeID')
    ALTER TABLE RecipeCuisines DROP CONSTRAINT fk_RecipeCuisines_RecipeCuisine_RecipeID;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_RecipeCuisines_RecipeCuisine_CuisineID')
    ALTER TABLE RecipeCuisines DROP CONSTRAINT fk_RecipeCuisines_RecipeCuisine_CuisineID;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_Reviews_Review_RecipeID')
    ALTER TABLE Reviews DROP CONSTRAINT fk_Reviews_Review_RecipeID;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_CookingSteps_CookingStep_RecipeID')
    ALTER TABLE CookingSteps DROP CONSTRAINT fk_CookingSteps_CookingStep_RecipeID;

-- Dropping Tables
DROP TABLE IF EXISTS Ingredients;
DROP TABLE IF EXISTS Recipes;
DROP TABLE IF EXISTS Cuisines;
DROP TABLE IF EXISTS RecipeCuisines;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS CookingSteps;


-- Dropping Views
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'RecipeDetails' AND type = 'V')
    DROP VIEW RecipeDetails;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'TopRatedRecipes' AND type = 'V')
    DROP VIEW TopRatedRecipes;

-- Dropping Stored Procedures
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'RecipesWithHighestRating' AND type = 'P')
    DROP PROCEDURE RecipesWithHighestRating;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'AverageRating' AND type = 'P')
    DROP PROCEDURE AverageRating;
GO

-- Creating Tables
-- Ingredients Table
CREATE TABLE Ingredients (
    Ingredient_ID INT PRIMARY KEY,
    Ingredient_Name NVARCHAR(255)
);

-- Recipes Table
CREATE TABLE Recipes (
    Recipe_ID INT PRIMARY KEY,
    Recipe_Name NVARCHAR(255),
    Recipe_PreparationTime INT,
    Recipe_DifficultyLevel NVARCHAR(50),
    Recipe_AverageRating DECIMAL(3, 2),
    Recipe_NumRatings INT,
    Recipe_IngredientID INT,
    Recipe_CookingStepsID INT,
    CONSTRAINT fk_Recipes_Recipe_IngredientID FOREIGN KEY (Recipe_IngredientID) REFERENCES Ingredients (Ingredient_ID)
);

-- Cuisines Table
CREATE TABLE Cuisines (
    Cuisine_ID INT PRIMARY KEY,
    Cuisine_Type NVARCHAR(255)
);

-- RecipeCuisines Table
CREATE TABLE RecipeCuisines (
    RecipeCuisine_RecipeID INT,
    RecipeCuisine_CuisineID INT,
    PRIMARY KEY (RecipeCuisine_RecipeID, RecipeCuisine_CuisineID),
    CONSTRAINT fk_RecipeCuisines_RecipeCuisine_RecipeID FOREIGN KEY (RecipeCuisine_RecipeID) REFERENCES Recipes (Recipe_ID),
    CONSTRAINT fk_RecipeCuisines_RecipeCuisine_CuisineID FOREIGN KEY (RecipeCuisine_CuisineID) REFERENCES Cuisines (Cuisine_ID)
);

-- Users Table
CREATE TABLE Users (
    User_ID INT IDENTITY PRIMARY KEY,
    User_Name NVARCHAR(255),
    User_Email NVARCHAR(255),
    User_Password NVARCHAR(255),
    ProfileInfo NVARCHAR(MAX),
    Preferences NVARCHAR(MAX)
);

-- Reviews Table
CREATE TABLE Reviews (
    Review_ID INT IDENTITY PRIMARY KEY,
    Review_RecipeID INT,
    Review_UserID INT,
    Review_Rating DECIMAL(3, 2),
    Review_Comment NVARCHAR(MAX),
    CONSTRAINT fk_Reviews_Review_RecipeID FOREIGN KEY (Review_RecipeID) REFERENCES Recipes (Recipe_ID)
);

-- CookingSteps Table
CREATE TABLE CookingSteps (
    CookingStep_ID INT PRIMARY KEY,
    CookingStep_RecipeID INT,
    CookingStep_StepNumber INT,
    CookingStep_Description NVARCHAR(MAX),
    CONSTRAINT fk_CookingSteps_CookingStep_RecipeID FOREIGN KEY (CookingStep_RecipeID) REFERENCES Recipes (Recipe_ID)
);


-- Creating Views
-- Recipe Details View
CREATE VIEW RecipeDetails AS
SELECT
    R.Recipe_ID,
    R.Recipe_Name,
    R.Recipe_PreparationTime,
    I.Ingredient_Name,
    CS.CookingStep_StepNumber,
    CS.CookingStep_Description
FROM Recipes R
JOIN Ingredients I ON R.Recipe_IngredientID = I.Ingredient_ID
JOIN CookingSteps CS ON R.Recipe_ID = CS.CookingStep_RecipeID;

-- Top Rated Recipes View
CREATE VIEW TopRatedRecipes AS
SELECT 
    R.Recipe_ID,
    R.Recipe_Name,
    AVG(REV.Review_Rating) AS Average_Rating,
    COUNT(REV.Review_ID) AS Total_Reviews
FROM Recipes R
LEFT JOIN Reviews REV ON R.Recipe_ID = REV.Review_RecipeID
GROUP BY R.Recipe_ID, R.Recipe_Name;

DROP PROCEDURE IF EXISTS RecipesWithHighestRating;
GO

CREATE PROCEDURE RecipesWithHighestRating
    @TopN INT
AS
BEGIN
    SELECT TOP (@TopN)
        R.Recipe_ID,
        R.Recipe_Name,
        AVG(REV.Review_Rating) AS Average_Rating
    FROM Recipes R
    LEFT JOIN Reviews REV ON R.Recipe_ID = REV.Review_RecipeID
    GROUP BY R.Recipe_ID, R.Recipe_Name
    ORDER BY Average_Rating DESC;
END;

GO


DROP PROCEDURE IF EXISTS AverageRating;
GO


SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Reviews';
GO
ALTER TABLE Reviews
ADD Review_Time DATETIME;
GO
UPDATE Reviews
SET Review_Time = GETDATE(); -- Sets the current date and time
GO

CREATE OR ALTER PROCEDURE AverageRating
    @recipeID INT
AS
BEGIN
    SELECT 
        REV.Review_ID,
        REV.Review_Rating,
        REV.Review_Comment,
        REV.Review_Time,
        AVG(CAST(REV.Review_Rating AS FLOAT)) 
            OVER (ORDER BY REV.Review_Time) AS Running_Average_Rating
    FROM 
        Reviews REV
    WHERE 
        REV.Review_RecipeID = @recipeID
    ORDER BY 
        REV.Review_Time;
END;
GO

EXEC AverageRating @recipeID = 1;
GO

-- Insert data into Ingredients table
INSERT INTO Ingredients (Ingredient_ID, Ingredient_Name) 
VALUES 
(1, 'Tomatoes'), 
(2, 'Fresh Mozzarella'), 
(3, 'Basil'), 
(4, 'Olive Oil'), 
(5, 'Salt'), 
(6, 'Pepper'), 
(7, 'Pasta'), 
(8, 'Pine Nuts'), 
(9, 'Cherry Tomatoes'), 
(10, 'Broccoli'), 
(11, 'Soy Sauce'), 
(12, 'Beef'), 
(13, 'Garlic'), 
(14, 'Chicken Breast'), 
(15, 'Romaine Lettuce'), 
(16, 'Parmesan Cheese'), 
(17, 'Salmon Fillet'), 
(18, 'Honey'), 
(19, 'Shrimp'), 
(20, 'Cooking Oil'), 
(21, 'Pumpkin'), 
(22, 'Chicken Skewers'), 
(23, 'Eggplant'), 
(24, 'Thai Noodles'), 
(25, 'Lasagna Noodles'), 
(26, 'Cauliflower'), 
(27, 'Mango'), 
(28, 'Quinoa'), 
(29, 'Lemon'), 
(30, 'Butter'), 
(31, 'Black Beans'), 
(32, 'Quesadilla Cheese'), 
(33, 'Salad Greens'), 
(34, 'Lentils'), 
(35, 'Cumin'), 
(36, 'Coriander Powder'), 
(37, 'Greek Yogurt'), 
(38, 'Vodka Sauce'), 
(39, 'Bell Peppers'), 
(40, 'Crispy Wings'), 
(41, 'Black Beans'), 
(42, 'Tofu'), 
(43, 'Stroganoff Sauce'), 
(44, 'Rice'), 
(45, 'Peaches'), 
(46, 'Cajun Seasoning'), 
(47, 'Brussels Sprouts'), 
(48, 'Bacon'), 
(49, 'Enchilada Sauce'), 
(50, 'Ginger'), 
(51, 'Roasted Red Peppers'), 
(52, 'Chickpeas'), 
(53, 'Pumpkin'), 
(54, 'Blueberries'), 
(55, 'Muffin Mix'), 
(56, 'Garlic Powder'), 
(57, 'Potatoes'), 
(58, 'Curry Powder'), 
(59, 'Pancake Mix'), 
(60, 'Veggies Stir-Fry Mix'), 
(61, 'Breadcrumbs'), 
(62, 'Mayonnaise'), 
(63, 'Mustard'), 
(64, 'Bread'), 
(65, 'Tuna');

-- Insert data into Cuisines table
INSERT INTO Cuisines (Cuisine_ID, Cuisine_Type) 
VALUES 
(1, 'Italian'), 
(2, 'Chinese'), 
(3, 'American'), 
(4, 'Japanese'), 
(5, 'Mexican'), 
(6, 'Thai'), 
(7, 'Mediterranean'), 
(8, 'Indian'), 
(9, 'Greek'), 
(10, 'British'), 
(11, 'French'), 
(12, 'Hawaiian'), 
(13, 'Middle Eastern'), 
(14, 'Russian');


-- Enable IDENTITY_INSERT
SET IDENTITY_INSERT Users ON;
-- Insert into Users
INSERT INTO Users (User_ID, User_Name, User_Email, User_Password, ProfileInfo, Preferences)
VALUES 
(1, 'jason_taylor', 'jason.taylor@email.com', 'jason_pass123', 'Project Manager at XYZ Projects.', 'Japanese and Italian cuisine'), 
(2, 'mia_carter', 'mia.carter@email.com', 'mia_pass789', 'Social Media Manager at SocialBuzz Agency.', 'Healthy and Vegetarian options'), 
(3, 'ethan_hall', 'ethan.hall@email.com', 'ethan_pass456', 'Fitness Instructor at FitZone Gym.', 'Protein-rich meals'), 
(4, 'natalie_perry', 'natalie.perry@email.com', 'natalie_pass789', 'Fashion Designer at TrendyStyles.', 'Mediterranean and French cuisine'), 
(5, 'william_fisher', 'william.fisher@email.com', 'william_pass123', 'Environmental Scientist at EcoSolutions.', 'Vegetarian and Sustainable cooking'), 
(6, 'ella_morris', 'ella.morris@email.com', 'ella_pass456', 'Event Planner at DreamEvents.', 'International cuisines'), 
(7, 'adam_cook', 'adam.cook@email.com', 'adam_pass789', 'Chef at GourmetDelights Restaurant.', 'Gourmet and Fusion recipes'), 
(8, 'ava_baker', 'ava.baker@email.com', 'ava_pass123', 'Graphic Illustrator at ArtCanvas Studio.', 'Vegetarian and Creative cooking'), 
(9, 'logan_hall', 'logan.hall@email.com', 'logan_pass456', 'Travel Blogger and Photographer.', 'World cuisine exploration'), 
(10, 'zoey_ross', 'zoey.ross@email.com', 'zoey_pass789', 'Digital Marketing Specialist at WebPromote.', 'Quick and Easy recipes'), 
(11, 'chris_harrison', 'chris.harrison@email.com', 'chris_pass123', 'Financial Advisor at FinanceHub.', 'Healthy and Low-carb meals'), 
(12, 'lily_wright', 'lily.wright@email.com', 'lily_pass789', 'Content Writer at WordCraft Agency.', 'Vegetarian and Asian cuisine'), 
(13, 'tyler_hall', 'tyler.hall@email.com', 'tyler_pass456', 'Civil Engineer at UrbanStructures.', 'Mediterranean and Mexican dishes'), 
(14, 'zoey_jackson', 'zoey.jackson@email.com', 'zoey_pass789', 'Graphic Designer at PixelPerfect Designs.', 'Creative and Fusion recipes'), 
(15, 'leo_martin', 'leo.martin@email.com', 'leo_pass123', 'Musician and Songwriter.', 'Quick and Comfort food'), 
(16, 'kate_smith', 'kate.smith@email.com', 'kate_pass789', 'Interior Decorator at ElegantSpaces.', 'Italian and French cuisine'), 
(17, 'nathan_brown', 'nathan.brown@email.com', 'nathan_pass456', 'Software Engineer at CodeCrafters.', 'Healthy and Protein-rich recipes'), 
(18, 'olivia_wilson', 'olivia.wilson@email.com', 'olivia_pass789', 'Fashion Stylist at VogueStyles.', 'Vegetarian and Trendy dishes'), 
(19, 'max_harrison', 'max.harrison@email.com', 'max_pass123', 'Photographer at LensCraft Studios.', 'International and Gourmet cuisine'), 
(20, 'lucy_morris', 'lucy.morris@email.com', 'lucy_pass456', 'Content Creator and YouTuber.', 'Quick and Easy recipes'), 
(21, 'jacob_baker', 'jacob.baker@email.com', 'jacob_pass789', 'Architect at ModernDesigns.', 'Vegetarian and Sustainable cooking'), 
(22, 'emma_jones', 'emma.jones@email.com', 'emma_pass123', 'Product Designer at TechInnovate.', 'Asian and Fusion cuisine'), 
(23, 'aiden_carter', 'aiden.carter@email.com', 'aiden_pass789', 'Fitness Trainer at FitLife Gym.', 'Protein-rich meals'), 
(24, 'zoey_robinson', 'zoey.robinson@email.com', 'zoey_pass456', 'UX/UI Designer at DigitalInnovate.', 'Creative and Fusion dishes'), 
(25, 'noah_fisher', 'noah.fisher@email.com', 'noah_pass789', 'Financial Analyst at FinTech Solutions.', 'Healthy and Low-carb recipes'), 
(26, 'amelia_hall', 'amelia.hall@email.com', 'amelia_pass123', 'Freelance Writer and Blogger.', 'Vegetarian and Trendy cooking'), 
(27, 'owen_perry', 'owen.perry@email.com', 'owen_pass456', 'Marketing Specialist at BrandPro Agency.', 'Mediterranean and French cuisine'), 
(28, 'lily_martin', 'lily.martin@email.com', 'lily_pass789', 'Software Developer at CodeGenius.', 'Asian and Fusion recipes'), 
(29, 'carter_davis', 'carter.davis@email.com', 'carter_pass123', 'Event Coordinator at DreamEvents.', 'Gourmet and Comfort food'), 
(30, 'grace_jackson', 'grace.jackson@email.com', 'grace_pass789', 'Digital Marketing Manager at WebBuzz.', 'Quick and Easy meals'), 
(31, 'hudson_brown', 'hudson.brown@email.com', 'hudson_pass123', 'Data Scientist at DataInnovate.', 'Healthy and Vegetarian options'), 
(32, 'scarlett_morris', 'scarlett.morris@email.com', 'scarlett_pass789', 'Content Creator and Instagram Influencer.', 'International and Trendy cuisine'), 
(33, 'jackson_fisher', 'jackson.fisher@email.com', 'jackson_pass456', 'Software Engineer at TechCrafters.', 'Asian and Fusion recipes'), 
(34, 'sophie_clark', 'sophie.clark@email.com', 'sophie_pass789', 'Marketing Coordinator at MarketTrend.', 'Healthy and Low-carb meals'), 
(35, 'mason_adams', 'mason.adams@email.com', 'mason_pass123', 'Graphic Designer at CreativeDesigns.', 'Vegetarian and Creative cooking'), 
(36, 'zoey_taylor', 'zoey.taylor@email.com', 'zoey_pass789', 'UX/UI Designer at DigitalInnovate.', 'Mediterranean and Japanese cuisine'), 
(37, 'ethan_davis', 'ethan.davis@email.com', 'ethan_pass456', 'Photographer at CaptureMoments.', 'Gourmet and Comfort food'), 
(38, 'emma_smith', 'emma.smith@email.com', 'emma_pass789', 'Financial Analyst at FinSolutions.', 'Healthy and Protein-rich recipes'), 
(39, 'oliver_hall', 'oliver.hall@email.com', 'oliver_pass123', 'Travel Blogger and Nature Enthusiast.', 'Vegetarian and Outdoor cooking'), 
(40, 'mia_robinson', 'mia.robinson@email.com', 'mia_pass456', 'Social Media Manager at BuzzMedia.', 'Trendy and Quick recipes'), 
(41, 'logan_carter', 'logan.carter@email.com', 'logan_pass789', 'Software Developer at CodeSprint.', 'Healthy and Vegetarian options'), 
(42, 'amelia_jones', 'amelia.jones@email.com', 'amelia_pass123', 'Digital Marketing Specialist at WebPro.', 'Mediterranean and Italian cuisine'), 
(43, 'noah_wilson', 'noah.wilson@email.com', 'noah_pass789', 'Fitness Trainer at FitZone Gym.', 'Protein-rich and Low-carb meals'), 
(44, 'grace_taylor', 'grace.taylor@email.com', 'grace_pass456', 'Content Writer at WordSmith.', 'Vegetarian and Creative cooking'), 
(45, 'jacob_adams', 'jacob.adams@email.com', 'jacob_pass789', 'Architect at GreenDesigns.', 'Sustainable and Gourmet cuisine'), 
(46, 'lily_hall', 'lily.hall@email.com', 'lily_pass123', 'Interior Decorator at DecorStudio.', 'Mediterranean and French dishes'), 
(47, 'aiden_robinson', 'aiden.robinson@email.com', 'aiden_pass456', 'Fitness Trainer at FitLife Gym.', 'Protein-rich meals'), 
(48, 'zoey_martin', 'zoey.martin@email.com', 'zoey_pass789', 'Software Developer at CodeGenius.', 'Asian and Fusion cuisine'), 
(49, 'emma_wilson', 'emma.wilson@email.com', 'emma_pass123', 'Product Designer at DesignCraft.', 'Trendy and Creative recipes'), 
(50, 'oliver_jackson', 'oliver.jackson@email.com', 'oliver_pass789', 'Software Engineer at DevSolutions.', 'Healthy and Quick meals');

-- Verify data
SELECT * FROM recipes;
GO


--Insert data into recipes table
INSERT INTO Recipes (Recipe_ID, Recipe_Name, Recipe_PreparationTime, Recipe_DifficultyLevel, Recipe_AverageRating, Recipe_NumRatings, Recipe_IngredientID, Recipe_CookingStepsID)
VALUES
(1, 'Caprese Salad', 15, 'Easy', 4.9, 150, 11, 11),
(2, 'Pesto Pasta with Cherry Tomatoes', 20, 'Medium', 4.5, 120, 12, 12),
(3, 'Beef and Broccoli Stir-Fry', 30, 'Medium', 4.4, 100, 13, 13),
(4, 'Chicken Caesar Salad', 25, 'Easy', 4.7, 130, 14, 14),
(5, 'Vegetarian Pizza', 20, 'Easy', 4.8, 110, 15, 15),
(6, 'Lentil Soup', 35, 'Easy', 4.6, 90, 16, 16),
(7, 'Honey Garlic Salmon', 40, 'Medium', 4.3, 80, 17, 17),
(8, 'Shrimp Fried Rice', 30, 'Medium', 4.5, 95, 18, 18),
(9, 'Pumpkin Soup', 25, 'Easy', 4.8, 105, 19, 19),
(10, 'Teriyaki Chicken Skewers', 35, 'Medium', 4.7, 115, 20, 20),
(11, 'Eggplant Parmesan', 40, 'Hard', 4.2, 85, 21, 21),
(12, 'Spicy Thai Noodles', 25, 'Medium', 4.6, 110, 22, 22),
(13, 'Classic Lasagna', 45, 'Hard', 4.4, 95, 23, 23),
(14, 'Cauliflower Wings', 30, 'Medium', 4.7, 105, 24, 24),
(15, 'Mango Salsa Chicken', 35, 'Medium', 4.5, 100, 25, 25),
(16, 'Quinoa Salad', 20, 'Easy', 4.9, 120, 26, 26),
(17, 'Lemon Butter Shrimp', 30, 'Medium', 4.8, 90, 27, 27),
(18, 'Tomato Basil Bruschetta', 15, 'Easy', 4.9, 140, 28, 28),
(19, 'Beef and Mushroom Pie', 40, 'Hard', 4.3, 80, 29, 29),
(20, 'Caramelized Onion Tart', 35, 'Medium', 4.6, 115, 30, 30),
(21, 'Greek Salad', 15, 'Easy', 4.8, 130, 31, 31),
(22, 'Penne alla Vodka', 25, 'Medium', 4.5, 110, 32, 32),
(23, 'Hawaiian Chicken Skewers', 30, 'Medium', 4.6, 120, 33, 33),
(24, 'Stuffed Bell Peppers', 35, 'Medium', 4.4, 95, 34, 34),
(25, 'Crispy Baked Chicken Wings', 40, 'Easy', 4.7, 105, 35, 35),
(26, 'Black Bean Quesadillas', 20, 'Easy', 4.9, 140, 36, 36),
(27, 'Teriyaki Salmon Bowl', 30, 'Medium', 4.5, 100, 37, 37),
(28, 'Sweet Potato Casserole', 45, 'Hard', 4.2, 85, 38, 38),
(29, 'Mushroom and Spinach Quiche', 25, 'Medium', 4.8, 115, 39, 39),
(30, 'Chicken Shawarma Wrap', 20, 'Medium', 4.7, 125, 40, 40),
(31, 'Butternut Squash Soup', 35, 'Easy', 4.6, 110, 41, 41),
(32, 'Lemon Garlic Butter Shrimp', 30, 'Medium', 4.5, 95, 42, 42),
(33, 'Tofu Stir-Fry', 25, 'Medium', 4.8, 120, 43, 43),
(34, 'Beef Stroganoff', 40, 'Hard', 4.3, 80, 44, 44),
(35, 'Chicken and Rice Casserole', 35, 'Medium', 4.6, 105, 45, 45),
(36, 'Peach Caprese Salad', 20, 'Easy', 4.9, 135, 46, 46),
(37, 'Cajun Shrimp Pasta', 30, 'Medium', 4.7, 115, 47, 47),
(38, 'Brussels Sprouts with Bacon', 25, 'Easy', 4.8, 95, 48, 48),
(39, 'Vegetarian Enchiladas', 35, 'Medium', 4.6, 100, 49, 49),
(40, 'Sesame Ginger Glazed Chicken', 30, 'Medium', 4.5, 110, 50, 50),
(41, 'Roasted Red Pepper Hummus', 20, 'Easy', 4.7, 120, 51, 51),
(42, 'Mango Avocado Salsa', 15, 'Easy', 4.9, 130, 52, 52),
(43, 'Crispy Tofu Tacos', 30, 'Medium', 4.5, 90, 53, 53),
(44, 'Garlic Herb Roasted Potatoes', 35, 'Easy', 4.8, 100, 54, 54),
(45, 'Chickpea Curry', 25, 'Medium', 4.6, 105, 55, 55),
(46, 'Pumpkin Pancakes', 20, 'Easy', 4.9, 110, 56, 56),
(47, 'Teriyaki Veggie Stir-Fry', 30, 'Medium', 4.7, 115, 57, 57),
(48, 'Blueberry Muffins', 25, 'Easy', 4.8, 120, 58, 58),
(49, 'Garlic Parmesan Roasted Broccoli', 35, 'Easy', 4.6, 95, 59, 59),
(50, 'Tuna Salad Sandwich', 20, 'Easy', 4.5, 100, 60, 60);


SELECT * FROM CookingSteps


-- Insert data into CookingSteps table
INSERT INTO CookingSteps (CookingStep_ID, CookingStep_RecipeID, CookingStep_StepNumber, CookingStep_Description) 
VALUES 
(1, 1, 1, 'Slice fresh tomatoes and mozzarella.'),
(2, 1, 2, 'Arrange tomato and mozzarella slices on a plate.'),
(3, 1, 3, 'Drizzle with balsamic glaze and sprinkle with fresh basil.'),
(4, 2, 1, 'Cook pasta according to package instructions.'),
(5, 2, 2, 'Sauté cherry tomatoes in olive oil until softened.'),
(6, 2, 3, 'Mix cooked pasta with sautéed cherry tomatoes and pesto sauce.'),
(7, 3, 1, 'Slice beef into thin strips.'),
(8, 3, 2, 'Stir-fry beef strips with broccoli in soy sauce.'),
(9, 3, 3, 'Serve beef and broccoli over rice.'),
(10, 4, 1, 'Chop romaine lettuce and grilled chicken.'),
(11, 4, 2, 'Toss lettuce and chicken with Caesar dressing.'),
(12, 4, 3, 'Top with croutons and grated parmesan.'),
(13, 5, 1, 'Spread tomato sauce on pizza dough.'),
(14, 5, 2, 'Add cheese and assorted vegetables as toppings.'),
(15, 5, 3, 'Bake until crust is golden and cheese is melted.'),
(16, 6, 1, 'Sauté onions, garlic, and lentils in olive oil.'),
(17, 6, 2, 'Add vegetable broth and simmer until lentils are cooked.'),
(18, 6, 3, 'Season with salt, pepper, and herbs.'),
(19, 7, 1, 'Pan-sear salmon fillets in honey and garlic.'),
(20, 7, 2, 'Serve salmon over a bed of mixed greens.'),
(21, 8, 1, 'Cook shrimp and rice separately.'),
(22, 8, 2, 'Sauté vegetables and combine with cooked shrimp and rice.'),
(23, 8, 3, 'Drizzle with soy sauce and stir-fry until heated through.'),
(24, 9, 1, 'Roast pumpkin until tender.'),
(25, 9, 2, 'Blend roasted pumpkin into a smooth soup.'),
(26, 9, 3, 'Season with spices and garnish with cream.'),
(27, 10, 1, 'Marinate chicken in teriyaki sauce.'),
(28, 10, 2, 'Skewer marinated chicken and grill until cooked.'),
(29, 10, 3, 'Serve skewers with rice and vegetables.'),
(30, 11, 1, 'Slice eggplant and dip in egg wash and breadcrumbs.'),
(31, 11, 2, 'Fry breaded eggplant until golden brown.'),
(32, 11, 3, 'Layer fried eggplant with marinara sauce and cheese, then bake.'),
(33, 12, 1, 'Sauté vegetables and tofu in a spicy Thai sauce.'),
(34, 12, 2, 'Toss cooked noodles with the spicy vegetable-tofu mixture.'),
(35, 12, 3, 'Garnish with peanuts and cilantro.'),
(36, 13, 1, 'Layer lasagna noodles with ricotta, marinara, and mozzarella.'),
(37, 13, 2, 'Repeat layers until the baking dish is filled.'),
(38, 13, 3, 'Bake until bubbly and golden brown.'),
(39, 14, 1, 'Coat cauliflower wings in a buffalo sauce.'),
(40, 14, 2, 'Bake until crispy and golden brown.'),
(41, 15, 1, 'Dice mango, tomatoes, and red onion.'),
(42, 15, 2, 'Mix diced ingredients with grilled chicken.'),
(43, 15, 3, 'Season with lime juice and cilantro.'),
(44, 16, 1, 'Combine cooked quinoa with assorted vegetables.'),
(45, 16, 2, 'Drizzle with lemon butter sauce and toss well.'),
(46, 16, 3, 'Garnish with fresh herbs.'),
(47, 17, 1, 'Sauté shrimp in lemon butter until cooked.'),
(48, 17, 2, 'Serve shrimp over a bed of linguine.'),
(49, 17, 3, 'Top with fresh parsley and lemon zest.'),
(50, 18, 1, 'Mix diced tomatoes, basil, and garlic.'),
(51, 18, 2, 'Spoon the mixture onto toasted baguette slices.'),
(52, 18, 3, 'Drizzle with balsamic glaze before serving.'),
(53, 19, 1, 'Brown ground beef and mushrooms in a skillet.'),
(54, 19, 2, 'Season with herbs and spices.'),
(55, 19, 3, 'Transfer the mixture to a pie crust and bake until golden brown.'),
(56, 20, 1, 'Caramelize onions in a skillet.'),
(57, 20, 2, 'Spread the caramelized onions on a tart crust.'),
(58, 20, 3, 'Top with shredded cheese and bake until bubbly.'),
(59, 21, 1, 'Assemble a Greek salad with tomatoes, cucumbers, olives, and feta.'),
(60, 21, 2, 'Drizzle with olive oil and sprinkle with oregano.'),
(61, 21, 3, 'Toss to combine all ingredients.'),
(62, 22, 1, 'Cook penne pasta according to package instructions.'),
(63, 22, 2, 'Simmer tomato vodka sauce in a separate pan.'),
(64, 22, 3, 'Combine cooked pasta with vodka sauce and stir well.'),
(65, 23, 1, 'Marinate chicken in a Hawaiian sauce.'),
(66, 23, 2, 'Skewer marinated chicken and grill until cooked.'),
(67, 23, 3, 'Serve skewers with pineapple and rice.'),
(68, 24, 1, 'Cut bell peppers in half and remove seeds.'),
(69, 24, 2, 'Stuff peppers with a mixture of ground turkey and rice.'),
(70, 24, 3, 'Bake until peppers are tender.');


INSERT INTO CookingSteps (CookingStep_ID, CookingStep_RecipeID, CookingStep_StepNumber, CookingStep_Description) 
VALUES 
(71, 25, 1, 'Bake chicken wings until crispy.'),
(72, 25, 2, 'Toss wings in a choice of sauce: buffalo, barbecue, or honey mustard.'),
(73, 25, 3, 'Serve with celery sticks and ranch dressing.'),
(74, 26, 1, 'Sauté black beans, corn, and spices in a pan.'),
(75, 26, 2, 'Layer the black bean mixture on tortillas with cheese.'),
(76, 26, 3, 'Fold the tortillas and cook until cheese is melted.'),
(77, 27, 1, 'Marinate salmon fillets in teriyaki sauce.'),
(78, 27, 2, 'Bake or grill salmon until flaky and cooked through.'),
(79, 27, 3, 'Serve over a bowl of steamed rice.'),
(80, 28, 1, 'Peel and dice sweet potatoes.'),
(81, 28, 2, 'Layer sweet potatoes in a casserole dish.'),
(82, 28, 3, 'Top with a mixture of brown sugar, pecans, and marshmallows, then bake until bubbly.'),
(83, 29, 1, 'Sauté mushrooms and spinach in olive oil.'),
(84, 29, 2, 'Whisk eggs and pour over the sautéed vegetables.'),
(85, 29, 3, 'Bake until the eggs are set.'),
(86, 30, 1, 'Marinate chicken in shawarma spices and yogurt.'),
(87, 30, 2, 'Grill or bake chicken until fully cooked.'),
(88, 30, 3, 'Assemble shawarma wraps with chicken, veggies, and tahini sauce.'),
(89, 31, 1, 'Roast butternut squash until tender.'),
(90, 31, 2, 'Blend roasted squash into a smooth soup with spices.'),
(91, 31, 3, 'Garnish with a drizzle of cream and fresh herbs.'),
(92, 32, 1, 'Sauté shrimp in garlic and lemon butter sauce.'),
(93, 32, 2, 'Toss shrimp with linguine and fresh parsley.'),
(94, 32, 3, 'Sprinkle with grated parmesan before serving.'),
(95, 33, 1, 'Dice tofu and stir-fry with a mix of colorful vegetables.'),
(96, 33, 2, 'Add a spicy Thai sauce and stir until well coated.'),
(97, 33, 3, 'Serve over a bed of rice.'),
(98, 34, 1, 'Sauté beef strips in a creamy stroganoff sauce.'),
(99, 34, 2, 'Serve over egg noodles and garnish with fresh herbs.'),
(100, 34, 3, 'Enjoy this hearty and comforting meal.'),
(101, 35, 1, 'Layer chicken and rice in a casserole dish.'),
(102, 35, 2, 'Cover with a creamy sauce and sprinkle with cheese.'),
(103, 35, 3, 'Bake until bubbly and golden brown.'),
(104, 36, 1, 'Dice peaches and tomatoes, and tear fresh mozzarella.'),
(105, 36, 2, 'Arrange ingredients on a plate and drizzle with balsamic glaze.'),
(106, 36, 3, 'Garnish with basil leaves.'),
(107, 37, 1, 'Sauté shrimp in Cajun spices until pink and opaque.'),
(108, 37, 2, 'Toss shrimp with linguine and a creamy Cajun sauce.'),
(109, 37, 3, 'Sprinkle with chopped green onions.'),
(110, 38, 1, 'Roast Brussels sprouts and bacon in the oven.'),
(111, 38, 2, 'Drizzle with balsamic glaze before serving.'),
(112, 38, 3, 'Garnish with shaved parmesan.'),
(113, 39, 1, 'Prepare tortillas with a filling of black beans and cheese.'),
(114, 39, 2, 'Crisp the tacos in a skillet until cheese is melted.'),
(115, 39, 3, 'Top with salsa and fresh cilantro.'),
(116, 40, 1, 'Toss chickpeas with a blend of curry spices.'),
(117, 40, 2, 'Simmer chickpeas in a tomato-based curry sauce.'),
(118, 40, 3, 'Serve over rice and garnish with cilantro.'),
(119, 41, 1, 'Prepare pancake batter with pumpkin puree and spices.'),
(120, 41, 2, 'Cook pancakes on a griddle until golden brown.'),
(121, 41, 3, 'Serve with maple syrup and chopped nuts.'),
(122, 42, 1, 'Sauté a mix of colorful vegetables in teriyaki sauce.'),
(123, 42, 2, 'Add tofu and stir until heated through.'),
(124, 42, 3, 'Serve over quinoa or rice.'),
(125, 43, 1, 'Mix blueberries into a classic muffin batter.'),
(126, 43, 2, 'Bake muffins until golden and a toothpick comes out clean.'),
(127, 43, 3, 'Enjoy these delightful blueberry muffins.'),
(128, 44, 1, 'Toss broccoli florets in a mixture of garlic and parmesan.'),
(129, 44, 2, 'Roast in the oven until broccoli is crispy.'),
(130, 44, 3, 'Sprinkle with additional parmesan before serving.'),
(131, 45, 1, 'Prepare tuna salad with a mix of mayo, celery, and seasoning.'),
(132, 45, 2, 'Spread tuna salad on bread slices for a classic sandwich.'),
(133, 45, 3, 'Serve with your favorite chips or a side salad.'),
(134, 46, 1, 'Roast red bell peppers until charred and tender.'),
(135, 46, 2, 'Peel and blend peppers into a smooth hummus.'),
(136, 46, 3, 'Serve hummus with pita bread or veggie sticks.'),
(137, 47, 1, 'Dice mangoes and avocados and mix with lime juice.'),
(138, 47, 2, 'Add diced tomatoes and red onion for a refreshing salsa.'),
(139, 47, 3, 'Serve with tortilla chips or as a topping for grilled chicken.'),
(140, 48, 1, 'Coat tofu cubes in a crispy coating and bake until golden.'),
(141, 48, 2, 'Assemble crispy tofu tacos with your favorite toppings.'),
(142, 48, 3, 'Drizzle with a zesty lime crema sauce.'),
(143, 49, 1, 'Toss cubed potatoes in a blend of garlic and herbs.'),
(144, 49, 2, 'Roast potatoes until crispy on the outside and tender on the inside.'),
(145, 49, 3, 'Sprinkle with parmesan for an extra kick.'),
(146, 50, 1, 'Sauté chickpeas and vegetables in a flavorful curry sauce.'),
(147, 50, 2, 'Serve over a bed of rice or your preferred grain.'),
(148, 50, 3, 'Garnish with fresh cilantro before serving.');

SELECT * FROM Reviews


SET IDENTITY_INSERT Reviews ON;


INSERT INTO Reviews (Review_ID, Review_RecipeID, Review_UserID, Review_Rating, Review_Comment, Review_Time)
VALUES
(1, 3, 12, 4.5, 'Great recipe! Loved the flavors.', '2024-11-01 14:32:00'),
(2, 7, 22, 3.8, 'Tasty, but a bit too spicy for me.', '2024-11-02 18:45:00'),
(3, 15, 8, 5.0, 'Amazing dish! Will definitely make it again.', '2024-11-03 19:12:00'),
(4, 2, 19, 4.2, 'Simple and delicious pasta dish.', '2024-11-04 20:01:00'),
(5, 12, 14, 3.5, 'Good, but I would add more seasoning next time.', '2024-11-05 15:00:00'),
(6, 20, 9, 4.8, 'The best pizza recipe ever!', '2024-11-06 16:42:00'),
(7, 8, 15, 4.0, 'Delicious salmon with a nice honey garlic glaze.', '2024-11-07 17:00:00'),
(8, 5, 7, 3.7, 'Not bad, but could use more veggies.', '2024-11-08 12:55:00'),
(9, 18, 25, 4.5, 'Impressive flavors in this curry!', '2024-11-09 09:34:00'),
(10, 14, 20, 4.2, 'Classic lasagna done right.', '2024-11-10 08:12:00'),
(11, 1, 5, 4.8, 'Perfectly balanced caprese salad!', '2024-11-11 14:45:00'),
(12, 19, 11, 3.5, 'Decent, but I prefer more spice in my pasta.', '2024-11-12 13:20:00'),
(13, 10, 28, 4.0, 'Delicious skewers with a fantastic teriyaki glaze.', '2024-11-13 17:30:00'),
(14, 13, 3, 4.7, 'Spicy noodles with the right amount of heat.', '2024-11-14 10:00:00'),
(15, 6, 32, 3.2, 'Lentil soup was a bit bland for my taste.', '2024-11-15 09:50:00'),
(16, 4, 2, 4.5, 'Crispy wings with a tasty cauliflower coating.', '2024-11-16 18:35:00'),
(17, 11, 16, 3.8, 'Eggplant parm was good, but a bit too cheesy.', '2024-11-17 13:45:00'),
(18, 16, 24, 4.2, 'Refreshing mango salsa on perfectly cooked chicken.', '2024-11-18 12:00:00'),
(19, 9, 10, 3.5, 'Quinoa salad was okay, needed more dressing.', '2024-11-19 14:55:00'),
(20, 17, 21, 4.8, 'Shrimp with a delicious lemon butter sauce.', '2024-11-20 19:12:00'),
(21, 21, 6, 3.7, 'Thai noodles were too spicy for my liking.', '2024-11-21 15:20:00'),
(22, 22, 29, 4.5, 'Classic lasagna done right.', '2024-11-22 16:40:00'),
(23, 23, 4, 3.8, 'Hawaiian chicken skewers were a hit at my party.', '2024-11-23 18:10:00'),
(24, 24, 31, 4.2, 'Stuffed bell peppers were a tasty and healthy option.', '2024-11-24 20:00:00'),
(25, 25, 23, 3.5, 'Crispy wings were a hit at the game night.', '2024-11-25 12:50:00'),
(26, 26, 30, 4.8, 'Black bean quesadillas were a flavorful delight.', '2024-11-26 19:30:00'),
(27, 27, 13, 4.0, 'Teriyaki salmon bowl was a quick and delicious meal.', '2024-11-27 17:45:00'),
(28, 28, 27, 3.7, 'Sweet potato casserole was a bit too sweet for me.', '2024-11-28 20:15:00'),
(29, 29, 18, 4.5, 'Mushroom and spinach quiche was a brunch favorite.', '2024-11-29 14:30:00'),
(30, 30, 8, 4.2, 'Chicken shawarma wrap had amazing flavors.', '2024-11-30 18:25:00'),
(31, 31, 9, 3.5, 'Butternut squash soup was a comforting dish.', '2024-12-01 10:50:00'),
(32, 32, 17, 4.8, 'Lemon garlic butter shrimp was a seafood delight.', '2024-12-02 19:50:00'),
(33, 33, 12, 4.0, 'Tofu stir-fry with a nice blend of veggies.', '2024-12-03 16:45:00'),
(34, 34, 26, 3.7, 'Beef stroganoff was a hearty and filling meal.', '2024-12-04 12:35:00'),
(35, 35, 22, 4.5, 'Chicken and rice casserole was a comforting dish.', '2024-12-05 13:25:00'),
(36, 36, 33, 4.2, 'Peach caprese salad was a refreshing summer option.', '2024-12-06 14:40:00'),
(37, 37, 7, 3.5, 'Cajun shrimp pasta had a nice kick to it.', '2024-12-07 15:00:00'),
(38, 38, 1, 4.8, 'Brussels sprouts with bacon was a tasty side dish.', '2024-12-08 14:55:00'),
(39, 39, 19, 4.0, 'Vegetarian enchiladas with a flavorful filling.', '2024-12-09 13:20:00'),
(40, 40, 11, 3.7, 'Sesame ginger glazed chicken was a hit at the dinner table.', '2024-12-10 12:10:00'),
(41, 41, 34, 4.5, 'Roasted red pepper hummus was a great appetizer.', '2024-12-11 16:45:00'),
(42, 42, 35, 4.2, 'Mango avocado salsa added a burst of flavors to the dish.', '2024-12-12 19:00:00'),
(43, 43, 15, 3.5, 'Crispy tofu tacos were a vegetarian delight.', '2024-12-13 12:50:00'),
(44, 44, 28, 4.8, 'Garlic herb roasted potatoes were a tasty side dish.', '2024-12-14 14:15:00'),
(45, 45, 32, 4.0, 'Chickpea curry was a hearty and flavorful dish.', '2024-12-15 13:30:00'),
(46, 46, 6, 3.7, 'Pumpkin pancakes were a great breakfast option.', '2024-12-16 15:45:00'),
(47, 47, 14, 4.5, 'Teriyaki veggie stir-fry was a quick and healthy meal.', '2024-12-17 17:10:00'),
(48, 48, 20, 4.2, 'Blueberry muffins were a delicious sweet treat.', '2024-12-18 11:35:00'),
(49, 49, 36, 3.5, 'Garlic parmesan roasted broccoli was a simple and tasty side.', '2024-12-19 19:15:00'),
(50, 50, 30, 4.8, 'Tuna salad sandwich was a classic lunch option.', '2024-12-20 13:20:00');


-- Enable IDENTITY_INSERT if required (adjust if RecipeID or CuisineID are auto-increment columns)
SET IDENTITY_INSERT RecipeCuisines ON;

SELECT * FROM RecipeCuisines

-- Insert data into RecipeCuisines table
INSERT INTO RecipeCuisines (RecipeCuisine_RecipeID, RecipeCuisine_CuisineID)
VALUES
(1, 1), 
(2, 1), 
(3, 2), 
(4, 3), 
(5, 1), 
(6, 7), 
(7, 4), 
(8, 2), 
(9, 3), 
(10, 4), 
(11, 1), 
(12, 6), 
(13, 1), 
(14, 3), 
(15, 5), 
(16, 7), 
(17, 3), 
(18, 1), 
(19, 10), 
(20, 11), 
(21, 9), 
(22, 1), 
(23, 12), 
(24, 3), 
(25, 5), 
(26, 5), 
(27, 4), 
(28, 3), 
(29, 11), 
(30, 13), 
(31, 3), 
(32, 5), 
(33, 3), 
(34, 7), 
(35, 14), 
(36, 1), 
(37, 3), 
(38, 3), 
(39, 5), 
(40, 2), 
(41, 7), 
(42, 5), 
(43, 5), 
(44, 3), 
(45, 8), 
(46, 3), 
(47, 4), 
(48, 3), 
(49, 3), 
(50, 3);


-- Verify the inserted data
SELECT * FROM RecipeCuisines;


-- Verify data in Ingredients table
SELECT * FROM Ingredients;

-- Verify data in Recipes table
SELECT * FROM Recipes;

-- Verify data in Cuisines table
SELECT * FROM Cuisines;

-- Verify data in RecipeCuisines table
SELECT * FROM RecipeCuisines;

-- Verify data in Users table
SELECT * FROM Users;

-- Verify data in Reviews table
SELECT * FROM Reviews;

-- Verify data in CookingSteps table
SELECT * FROM CookingSteps;

GO

