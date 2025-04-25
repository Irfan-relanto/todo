FROM python:3.10-slim-buster

# Create a non-root user
RUN useradd -m dockeruser

# Install expect for password-based shell access control
RUN apt-get update && apt-get install -y expect && apt-get clean

# Create the authentication script using expect
RUN echo '#!/usr/bin/expect -f\n\
set timeout 60\n\
set password "secure_password_here"\n\
\n\
puts "Authentication required to access this container."\n\
puts -nonewline "Password: "\n\
flush stdout\n\
stty -echo\n\
expect_user -re "(.*)\n"\n\
stty echo\n\
puts ""\n\
set input $expect_out(1,string)\n\
\n\
if {$input == $password} {\n\
    puts "Access granted."\n\
    spawn /bin/bash.original -l\n\
    interact\n\
} else {\n\
    puts "Authentication failed."\n\
    exit 1\n\
}' > /usr/local/bin/auth.exp && \
    chmod +x /usr/local/bin/auth.exp

# Replace default bash with auth wrapper
RUN cp /bin/bash /bin/bash.original && \
    echo '#!/bin/bash.original\n\
exec /usr/local/bin/auth.exp' > /bin/bash && \
    chmod +x /bin/bash

# Set working directory
WORKDIR /todo-app

# Copy requirements first and install dependencies
COPY requirements.txt .
RUN /bin/bash.original -c "pip install --no-cache-dir -r requirements.txt || echo 'No requirements.txt found, skipping pip install'"

# Copy the rest of the app
COPY . .

# Set proper permissions for the app
RUN chown -R dockeruser:dockeruser /todo-app

# Expose your app's port
EXPOSE 8089

# Run the app
CMD ["python3", "main.py"]
