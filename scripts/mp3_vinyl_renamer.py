import os
import yaml

def load_config(config_path):
    """Load the renaming configuration from a YAML file."""
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def get_files_in_directory(directory_path):
    """Get a sorted list of filenames in the directory."""
    return sorted(os.listdir(directory_path))

def rename_files(directory_path, config):
    """Rename files in the directory based on the provided configuration."""
    files = get_files_in_directory(directory_path)

    for i, file_name in enumerate(files):
        for rename_rule in config['renaming_scheme']:
            # Match the old_name_pattern and rename the file
            if rename_rule['old_name_pattern'] in file_name:
                old_file_path = os.path.join(directory_path, file_name)
                new_file_name = rename_rule['new_name']
                new_file_path = os.path.join(directory_path, new_file_name)
                os.rename(old_file_path, new_file_path)
                print(f"Renamed: {file_name} -> {new_file_name}")
                break  # Once matched and renamed, no need to check further rules

if __name__ == "__main__":
    directory = "/Volumes/MUSIC/Reloop Tape"  # Change this to your target directory
    config_file = "config.yaml"  # Path to the config file

    # Load the config file
    config = load_config(config_file)

    # Rename files based on the configuration
    rename_files(directory, config)
