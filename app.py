import pandas as pd
import streamlit as st
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.ensemble import RandomForestClassifier

# Load data
df = pd.read_csv('data.csv')

# Data preprocessing
# Replace duplicate values in 'Classes' column
df['Classes  '] = df['Classes  '].str.strip().replace({'fire': 'fire', 'not fire': 'not fire','not fire   ':'not fire',
                                                       'fire   ':'fire','fire ':'fire','not fire ':'not fire','not fire     ': 'not fire',
                                                       'not fire    ': 'not fire'})

# Label encoding
label = LabelEncoder()
df['Classes  '] = label.fit_transform(df['Classes  '])

# Handle non-numeric values by replacing them with NaN
df = df.apply(pd.to_numeric, errors='coerce')

# Drop rows containing NaN values
df = df.dropna()

# Standardize features
scale = StandardScaler()
features = ['Temperature', ' RH', ' Ws', 'Rain ', 'FWI']
df[features] = scale.fit_transform(df[features])

# Train-test split
x = df[features].values
y = df['Classes  '].values

# Model training - Random Forest
clf = RandomForestClassifier()
clf.fit(x, y)

# Streamlit UI
st.title('Forest Fire Prediction')

# Sidebar for user input
st.sidebar.header('User Input')
temperature = st.sidebar.slider('Temperature', min_value=0.0, max_value=40.0, step=0.1)
rh = st.sidebar.slider('Relative Humidity', min_value=0, max_value=100, step=1)
ws = st.sidebar.slider('Wind Speed', min_value=0, max_value=10, step=1)
rain = st.sidebar.slider('Rainfall', min_value=0.0, max_value=30.0, step=0.1)
fwi = st.sidebar.selectbox('FWI (Fire Weather Index)', ['low', 'moderate', 'high', 'very high', 'extreme'])

# Convert categorical FWI values to numeric
fwi_mapping = {'low': 0, 'moderate': 1, 'high': 2, 'very high': 3, 'extreme': 4}
fwi_numeric = fwi_mapping[fwi]

# Predict on user input
input_data = [[temperature, rh, ws, rain, fwi_numeric]]
prediction = clf.predict(input_data)

# Display prediction
st.subheader('Prediction')
if prediction[0] == 0:
    st.write('Predicted Class: not fire')
else:
    st.write('Predicted Class: fire')
