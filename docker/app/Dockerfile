# Use a minimal base image for the final output
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy built APK from builder stage
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk ./app.apk

# Command to keep the container alive (if needed for distribution)
CMD ["tail", "-f", "/dev/null"]