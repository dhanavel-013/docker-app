# Use official nginx image
FROM nginx:alpine

# Copy HTML and CSS to Nginx web directory
COPY . /usr/share/nginx/html

# Expose port 80 (used internally)
EXPOSE 80
