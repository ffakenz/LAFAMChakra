import requests
import os
import typing as tp
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

PINATA_BASE_URL = 'https://api.pinata.cloud/'
endpoint = 'pinning/pinFileToIPFS'
headers = {'pinata_api_key': os.getenv('PINATA_API_KEY'),
           'pinata_secret_api_key': os.getenv('PINATA_API_SECRET')}

chakras = ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]


for chakra in chakras:
    print(chakra)
    chakra_id = str(chakras.index(chakra))
    img_path = "./img/chakra-" + chakra + ".png"
    img_name = chakra_id + ".png"
    print(img_name)
    with Path(img_path).open("rb") as fp:
        image_binary = fp.read()
        response = requests.post(PINATA_BASE_URL + endpoint,
                                files={"file": (img_name, image_binary)},
                                headers=headers)
        print(response.json())


    
    metadata_path = "./metadata/chakra-" + chakra + ".json"
    metadata_name = chakra_id + ".json"
    print(metadata_name)
    with Path(metadata_path).open("rb") as fp:
        image_binary = fp.read()
        response = requests.post(PINATA_BASE_URL + endpoint,
                                files={"file": (metadata_name, image_binary)},
                                headers=headers)
        print(response.json())


# Custom tpe hints
ResponsePayload = tp.Dict[str, tp.Any]
OptionsDict = tp.Dict[str, tp.Any]
Headers = tp.Dict[str, str]

# global constants
API_ENDPOINT: str = "https://api.pinata.cloud/"


def pin_file_to_ipfs(self, path_to_file: str, options: tp.Optional[OptionsDict] = None) -> ResponsePayload:

    url: str = API_ENDPOINT + "pinning/pinFileToIPFS"
    headers: Headers = { k: self._auth_headers[k] for k in ["pinata_api_key", "pinata_secret_api_key"] }

    def get_all_files(directory: str) -> tp.List[str]:
        """get a list of absolute paths to every file located in the directory"""
        paths: tp.List[str] = []
        for root, dirs, files_ in os.walk(os.path.abspath(directory)):
            for file in files_:
                paths.append(os.path.join(root, file))
        return paths

    files: tp.List[str, tp.Any]

    if os.path.isdir(path_to_file):
        all_files: tp.List[str] = get_all_files(path_to_file)
        files = [("file",(file, open(file, "rb"))) for file in all_files]
    else:
        files = [("file", open(path_to_file, "rb"))]

    if options is not None:
        if "pinataMetadata" in options:
            headers["pinataMetadata"] = options["pinataMetadata"]
        if "pinataOptions" in options:
            headers["pinataOptions"] = options["pinataOptions"]
    response: requests.Response = requests.post(url=url, files=files, headers=headers)
    return response.json() if response.ok else self._error(response)  # type: ignore
