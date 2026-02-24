#!/bin/sh

# Replace placeholder with environment variable
if [ -n "$VITE_API_BASE_URL" ]; then
    echo "Replacing __API_URL_PLACEHOLDER__ with $VITE_API_BASE_URL"
    # Find all JS files in dist/assets and replace the placeholder
    find /app/dist/assets -name "*.js" -exec sed -i "s|__API_URL_PLACEHOLDER__|$VITE_API_BASE_URL|g" {} +
fi

# Start the application
exec serve -s dist -l 3000
