import click
import sys
from .commands import search, info, security, submit, list_cmd, approve, reject
from .config import Config
from .utils import setup_logging

@click.group()
@click.option('--api-url', envvar='FOSS_API_URL', default='http://localhost:8000',
              help='FOSS API base URL')
@click.option('--token', envvar='FOSS_API_TOKEN', default='',
              help='API authentication token')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
@click.option('--json', 'output_json', is_flag=True, help='Output as JSON')
@click.pass_context
def cli(ctx, api_url, token, verbose, output_json):
    """
    FOSS Package CLI - Manage packages in the FOSS ecosystem
    
    Examples:
      foss-cli search requests
      foss-cli info requests 2.31.0
      foss-cli security flask
      foss-cli submit axios 1.6.2 --type npm --token YOUR_TOKEN
    """
    ctx.ensure_object(dict)
    ctx.obj['config'] = Config(
        api_url=api_url,
        api_token=token,
        verbose=verbose,
        output_json=output_json
    )
    setup_logging(verbose)


# Register commands
cli.add_command(search.search)
cli.add_command(info.info)
cli.add_command(security.security)
cli.add_command(submit.submit)
cli.add_command(list_cmd.list_packages)
cli.add_command(approve.approve)
cli.add_command(reject.reject)


def main():
    """Main entry point for the CLI"""
    try:
        cli(obj={})
    except KeyboardInterrupt:
        click.echo("\nAborted!", err=True)
        sys.exit(130)
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
