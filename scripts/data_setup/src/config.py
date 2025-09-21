from scrap.arsenal_strength import ArsenalStrengthScraper
from scrap.atlantis import AtlantisScraper
from scrap.booty_builder import BootyBuilderScraper
from scrap.cybex import CybexScraper
from scrap.drax import DraxScraper
from scrap.dynaforce import DynaforceScraper
from scrap.freemotion import FreemotionScraper
from scrap.gym80 import Gym80Scraper
from scrap.gymleco import GymlecoScraper
from scrap.hammer_strength import HammerStrengthScraper
from scrap.hoist import HoistScraper
from scrap.legend_fitness import LegendFitnessScraper
from scrap.Lexco import LexcoScraper
from scrap.life_fitness import LifeFitnessScraper
from scrap.matrix import MatrixScraper
from scrap.nautilus import NautilusScraper
from scrap.new_tech import NewTechScraper
from scrap.panatta import PanattaScraper
from scrap.precor import PrecorScraper
from scrap.prime_fitness import PrimeScraper
from scrap.techno_gym import TechnoGymScraper
from scrap.usp import USPScraper
from scrap.viliti import VilitiScraper

scrap_configs = [
    {
        "scraper": ArsenalStrengthScraper(
            machine_series="Plate-loaded", type_="Plate-loaded"),
        "urls": [
            "https://www.ironcompany.com/strength-training-equipment/"
            "plate-loaded-leverage-gym-equipment/brand-arsenal_strength"
        ],
    },
    {
        "scraper": ArsenalStrengthScraper(
            machine_series="Selectorized", type_="Selectorized"),
        "urls": [
            "https://www.ironcompany.com/strength-training-equipment/"
            "selectorized-gym-equipment/brand-arsenal_strength"
        ],
    },
    {
        "scraper": AtlantisScraper(),
        "urls": [
            "https://rawfitnessequipment.com.au/collections/atlantis?page=3"
            "&srsltid=AfmBOopi1LGGTpbWS3VpyoP52QgVwBorbevELH45tviUtGs7c0ozNg-C"
        ],
    },
    {
        "scraper": BootyBuilderScraper(type_="Plate-loaded"),
        "urls": [
            "https://bootybuilder.com/product-category/machines/"
            "plate-loaded-machines/"
        ],
    },
    {
        "scraper": BootyBuilderScraper(type_="Selectorized"),
        "urls": [
            "https://bootybuilder.com/product-category/machines/"
            "weight-stack-machines/"
        ],
    },
    {
        "scraper": CybexScraper(),
        "urls": [
            f"https://bestgymequipment.co.uk/collections/cybex?page={i}&grid_list=grid-view"
            for i in range(1, 6)
        ],
    },
    {
        "scraper": DraxScraper(machine_series="Welliv Pro"),
        "urls": ["https://www.draxfit.com/ko/strength/welliv-pro/products"],
    },
    {
        "scraper": DraxScraper(machine_series="Welliv"),
        "urls": ["https://www.draxfit.com/ko/strength/welliv/products"],
    },
    {
        "scraper": DraxScraper(machine_series="Welliv Pro Dual"),
        "urls": [
            "https://www.draxfit.com/ko/strength/welliv-pro-dual/products"
        ],
    },
    {
        "scraper": DraxScraper(machine_series="Plate-loaded"),
        "urls": ["https://www.draxfit.com/ko/strength/plate-loaded/products"],
    },
    {
        "scraper": DynaforceScraper(),
        "urls": [
            "http://www.dynaforce.co.kr/bbs/board.php?bo_table=weight&page={i}"
            for i in range(1, 3)
        ],
    },
    {
        "scraper": DynaforceScraper(),
        "urls": ["http://www.dynaforce.co.kr/bbs/board.php?bo_table=hammer"],
    },
    {
        "scraper": FreemotionScraper(machine_series="Genesis"),
        "urls": ["https://freemotionfitness.com/strength-machines/genesis/"],
    },
]