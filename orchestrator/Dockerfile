FROM python:3.12

# Set the working directory
WORKDIR /orchestrator_app

# Copy the current directory contents into the container at /orchestrator_app
COPY . .

# Create a virtual environment and install the dependencies
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt

# Expose port 5000 for the Flask app to listen on
EXPOSE 5000

# Activate the virtual environment and run the app
CMD . venv/bin/activate && python orchestrator.py
