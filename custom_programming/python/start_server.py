#!/usr/bin/env python3
"""
Startup script for C++ Compiler API Server
Provides easy server management with configuration options
"""

import os
import sys
import argparse
import subprocess
import socket
import time
from pathlib import Path

def check_dependencies():
    """Check if required Python packages are installed"""
    try:
        import flask
        import flask_cors
        print("✅ Flask dependencies found")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("📦 Installing required packages...")
        
        try:
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", 
                "flask", "flask-cors", "werkzeug"
            ])
            print("✅ Dependencies installed successfully")
            return True
        except subprocess.CalledProcessError:
            print("❌ Failed to install dependencies")
            return False

def get_local_ip():
    """Get local IP address"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "127.0.0.1"

def check_port_available(port):
    """Check if port is available"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(("0.0.0.0", port))
        sock.close()
        return True
    except OSError:
        return False

def show_startup_info(host, port):
    """Display server startup information"""
    local_ip = get_local_ip()
    
    print("=" * 70)
    print("🚀 C++ COMPILER API SERVER")
    print("=" * 70)
    print(f"🌐 Server URL: http://{host}:{port}")
    print(f"📱 Mobile App URL: http://{local_ip}:{port}")
    print(f"🏠 Local Access: http://localhost:{port}")
    print("=" * 70)
    print("📋 API Endpoints:")
    print(f"   GET  http://{local_ip}:{port}/health      - Health check")
    print(f"   POST http://{local_ip}:{port}/compile     - Compile C++ code")
    print(f"   GET  http://{local_ip}:{port}/examples    - Get example programs")
    print("=" * 70)
    print("📝 Flutter App Configuration:")
    print(f"   Server IP: {local_ip}")
    print(f"   Port: {port}")
    print("=" * 70)
    print("🔧 Controls:")
    print("   • Press Ctrl+C to stop server")
    print("   • Use --help for more options")
    print("=" * 70)

def main():
    """Main startup function"""
    parser = argparse.ArgumentParser(
        description="C++ Compiler API Server - Mobile App Backend",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python start_server.py                    # Start with defaults (0.0.0.0:5000)
  python start_server.py --port 8080       # Use different port
  python start_server.py --host 192.168.1.10  # Bind to specific IP
  python start_server.py --debug           # Enable debug mode
        """
    )
    
    parser.add_argument('--host', default='0.0.0.0', 
                       help='Host address to bind (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=5000, 
                       help='Port number (default: 5000)')
    parser.add_argument('--debug', action='store_true', 
                       help='Enable debug mode')
    parser.add_argument('--check-deps', action='store_true', 
                       help='Check and install dependencies only')
    
    args = parser.parse_args()
    
    # Check dependencies first
    if not check_dependencies():
        sys.exit(1)
    
    if args.check_deps:
        print("✅ Dependencies check completed")
        return
    
    # Validate port
    if args.port < 1 or args.port > 65535:
        print(f"❌ Invalid port number: {args.port}")
        sys.exit(1)
    
    if not check_port_available(args.port):
        print(f"❌ Port {args.port} is already in use")
        print(f"💡 Try using a different port with --port <number>")
        sys.exit(1)
    
    # Check if server.py exists
    server_path = Path(__file__).parent / "server.py"
    if not server_path.exists():
        print(f"❌ server.py not found at {server_path}")
        print("💡 Make sure you're running this from the python directory")
        sys.exit(1)
    
    # Show startup information
    show_startup_info(args.host, args.port)
    
    try:
        # Start server
        cmd = [sys.executable, "server.py", "--host", args.host, "--port", str(args.port)]
        if args.debug:
            cmd.append("--debug")
        
        print("🚀 Starting server...")
        time.sleep(1)
        
        subprocess.run(cmd, check=True)
        
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Server failed to start: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ Python executable not found")
        sys.exit(1)

if __name__ == "__main__":
    main()