# Mega Outlet App - Polish E-commerce Shopping App

## Project Overview
A Flutter-based Android shopping application that integrates with mega-outlet.pl (WooCommerce/WordPress) via REST API.

## Status
- **Build**: Debug APK successfully built (158 MB)
- **Location**: `/workspace/project/mega_outlet_app/build/app/outputs/flutter-apk/app-debug.apk`

## Tech Stack
- Flutter 3.41.6
- Dart SDK 3.11.4
- Android SDK 34/36
- Java 21

## Dependencies
- **State Management**: flutter_bloc 8.1.6, equatable 2.0.5
- **Networking**: dio 5.4.3+1, http 1.0.0
- **UI**: cached_network_image, carousel_slider, flutter_svg
- **Storage**: shared_preferences, flutter_secure_storage, sqflite
- **Navigation**: go_router 14.2.7

## Architecture
- Feature-based architecture with clean separation
- Core: API client, constants, theme, error handling
- Features: product, cart, auth, account, checkout, home

## Features Implemented
- Home page with categories and featured products
- Product list with grid/list views
- Product details with images, description, stock
- Add to cart functionality
- Cart management
- User login/register
- Account page

## API Integration
- WooCommerce Store API v1
- Products: `/wc/store/v1/products`
- Categories: `/wc/store/v1/products/categories`
- Cart: `/wc/store/v1/cart`

## Notes
- Firebase plugins included but not configured (messaging, notifications)
- Uses Polish language throughout (UI labels, messages)