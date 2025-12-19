import logging
import json
import click
from typing import Any, Dict, List
from rich.console import Console
from rich.table import Table
from rich import box

console = Console()


def setup_logging(verbose: bool = False):
    """Setup logging configuration"""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


def output_json(data: Any):
    """Output data as JSON"""
    click.echo(json.dumps(data, indent=2))


def output_table(data: List[Dict[str, Any]], columns: List[str], title: str = ""):
    """Output data as a formatted table"""
    if not data:
        console.print("[yellow]No results found[/yellow]")
        return
    
    table = Table(title=title, box=box.ROUNDED, show_header=True, header_style="bold magenta")
    
    # Add columns
    for col in columns:
        table.add_column(col.replace('_', ' ').title())
    
    # Add rows
    for item in data:
        row = [str(item.get(col, '')) for col in columns]
        table.add_row(*row)
    
    console.print(table)


def format_package_info(package: Dict[str, Any]) -> str:
    """Format package information for display"""
    lines = [
        f"[bold cyan]Package:[/bold cyan] {package.get('name')}",
        f"[bold cyan]Version:[/bold cyan] {package.get('version')}",
        f"[bold cyan]Type:[/bold cyan] {package.get('type')}",
        f"[bold cyan]Status:[/bold cyan] {package.get('status')}",
    ]
    
    if package.get('description'):
        lines.append(f"[bold cyan]Description:[/bold cyan] {package.get('description')}")
    
    if package.get('license'):
        lines.append(f"[bold cyan]License:[/bold cyan] {package.get('license')}")
    
    if package.get('security_score') is not None:
        score = package.get('security_score')
        color = 'green' if score >= 90 else 'yellow' if score >= 70 else 'red'
        lines.append(f"[bold cyan]Security Score:[/bold cyan] [{color}]{score}/100[/{color}]")
    
    if package.get('approved_by'):
        lines.append(f"[bold cyan]Approved By:[/bold cyan] {package.get('approved_by')}")
        lines.append(f"[bold cyan]Approved Date:[/bold cyan] {package.get('approved_date')}")
    
    return '\n'.join(lines)


def format_scan_result(scan: Dict[str, Any]) -> str:
    """Format security scan result"""
    vulns = scan.get('vulnerabilities', {})
    score = scan.get('security_score', 0)
    
    score_color = 'green' if score >= 90 else 'yellow' if score >= 70 else 'red'
    
    lines = [
        f"[bold cyan]Scan ID:[/bold cyan] {scan.get('scan_id')}",
        f"[bold cyan]Package:[/bold cyan] {scan.get('package')} {scan.get('version')}",
        f"[bold cyan]Scan Date:[/bold cyan] {scan.get('scan_date')}",
        f"[bold cyan]Security Score:[/bold cyan] [{score_color}]{score}/100[/{score_color}]",
        "",
        "[bold cyan]Vulnerabilities:[/bold cyan]",
        f"  Critical: {vulns.get('critical', 0)}",
        f"  High:     {vulns.get('high', 0)}",
        f"  Medium:   {vulns.get('medium', 0)}",
        f"  Low:      {vulns.get('low', 0)}",
        f"  Total:    {vulns.get('total', 0)}",
        "",
        f"[bold cyan]Approval Recommended:[/bold cyan] {'✓ Yes' if scan.get('approval_recommended') else '✗ No'}",
        f"[bold cyan]Scan Tools:[/bold cyan] {', '.join(scan.get('scan_tools', []))}",
    ]
    
    return '\n'.join(lines)


def success(message: str):
    """Print success message"""
    console.print(f"[green]✓[/green] {message}")


def error(message: str):
    """Print error message"""
    console.print(f"[red]✗[/red] {message}", err=True)


def warning(message: str):
    """Print warning message"""
    console.print(f"[yellow]![/yellow] {message}")


def info(message: str):
    """Print info message"""
    console.print(f"[blue]ℹ[/blue] {message}")


def generate_token() -> str:
    """Generate a secure API token"""
    import secrets
    return secrets.token_urlsafe(32)


def check_auth_status(config):
    """Check and display authentication status"""
    if config.has_token:
        info("Authentication: Enabled")
        return True
    else:
        warning("Authentication: Not configured")
        console.print("  Set FOSS_API_TOKEN environment variable or use --token option")
        return False


def format_auth_error(error_response: dict) -> str:
    """Format authentication error message"""
    detail = error_response.get('detail', 'Authentication failed')
    
    if 'Missing API key' in detail:
        return (
            "Authentication required but no token provided.\n"
            "Set FOSS_API_TOKEN environment variable or use --token option.\n"
            f"Generate token: python3 -c \"import secrets; print(secrets.token_urlsafe(32))\""
        )
    elif 'Invalid API key' in detail:
        return (
            "Invalid API token provided.\n"
            "Check that your token matches the server configuration."
        )
    else:
        return detail
