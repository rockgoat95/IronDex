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

SCRAP_CONFIG = [
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
        "scraper": DraxScraper(machine_series="Welliv Pro", type_="Selectorized"),
        "urls": ["https://www.draxfit.com/ko/strength/welliv-pro/products"],
    },
    {
        "scraper": DraxScraper(machine_series="Welliv", type_="Selectorized"),
        "urls": ["https://www.draxfit.com/ko/strength/welliv/products"],
    },
    {
        "scraper": DraxScraper(machine_series="Welliv Pro Dual", type_="Selectorized"),
        "urls": [
            "https://www.draxfit.com/ko/strength/welliv-pro-dual/products"
        ],
    },
    {
        "scraper": DraxScraper(machine_series="Plate-loaded", type_="Plate-loaded"),
        "urls": ["https://www.draxfit.com/ko/strength/plate-loaded/products"],
    },
    {
        "scraper": DynaforceScraper(type_="Selectorized"),
        "urls": [
            "http://www.dynaforce.co.kr/bbs/board.php?bo_table=weight&page={i}"
            for i in range(1, 3)
        ],
    },
    {
        "scraper": DynaforceScraper(type_="Plate-loaded"),
        "urls": ["http://www.dynaforce.co.kr/bbs/board.php?bo_table=hammer"],
    },
    {
        "scraper": FreemotionScraper(machine_series="Genesis", type_="Selectorized"),
        "urls": ["https://freemotionfitness.com/strength-machines/genesis/"],
    },
    {
        "scraper": FreemotionScraper(machine_series="Genesis DS", type_="Selectorized"),
        "urls": ["https://freemotionfitness.com/strength-machines/genesis-ds/"],
    },
    {
        "scraper": FreemotionScraper(machine_series="Epic Selectorized", type_="Selectorized"),
        "urls": ["https://freemotionfitness.com/strength-machines/epic-selectorized/"],
    },
    {
        "scraper": FreemotionScraper(machine_series="Epic Plate-Loaded", type_="Plate-loaded"),
        "urls": ["https://freemotionfitness.com/strength-machines/epic-plate-loaded/"],
    },
    {
        "scraper": Gym80Scraper("Sygnum", "Selectorized"),
        "urls": ["https://www.gym80.co.uk/product-ranges/sygnum"],
    },
    {
        "scraper": Gym80Scraper("Sygnum Dual", "Selectorized"),
        "urls": ["https://www.gym80.co.uk/product-ranges/sygnum-dual"],
    },
    {
        "scraper": Gym80Scraper("Sygnum Cable Art", "Selectorized"),
        "urls": ["https://www.gym80.co.uk/product-ranges/sygnum-cable-art"],
    },
    {
        "scraper": Gym80Scraper("Sygnum Combo", "Selectorized"),
        "urls": ["https://www.gym80.co.uk/product-ranges/sygnum-combo"],
    },
    {
        "scraper": Gym80Scraper("Sygnum Stations", "Selectorized"),
        "urls": ["https://www.gym80.co.uk/product-ranges/sygnum-stations"],
    },
    {
        "scraper": Gym80Scraper("Pure Kraft Strong", "Plate-loaded"),
        "urls": ["https://www.gym80.co.uk/product-ranges/pure-kraft-strong"],
    },
    {
        "scraper": Gym80Scraper("Pure Kraft", "Plate-loaded"),
        "urls": ["https://www.gym80.co.uk/product-ranges/pure-kraft"],
    },
    {
        "scraper": Gym80Scraper("80Athletics", "Plate-loaded"),
        "urls": ["https://www.gym80.co.uk/product-ranges/80athletics"],
    },
    {
        "scraper": Gym80Scraper("Outdoor", "Plate-loaded"),
        "urls": ["https://www.gym80.co.uk/product-ranges/outdoor"],
    },
    {
        "scraper": GymlecoScraper(type_="Plate-loaded"),
        "urls": ["https://gymleco.com/collections/plate-loaded-machines"],
    },
    {
        "scraper": GymlecoScraper(type_="Selectorized"),
        "urls": ["https://gymleco.com/collections/cable-stations"],
    },
    {
        "scraper": GymlecoScraper(type_="Selectorized"),
        "urls": ["https://gymleco.com/collections/selectorized-gym-machines"],
    },
    {
        "scraper": GymlecoScraper(type_="Selectorized"),
        "urls": ["https://gymleco.com/collections/combi-machines"],
    },
    {
        "scraper": HammerStrengthScraper(),
        "urls": [
            "https://www.lifefitness.com/en-us/catalog?Brand=1053&Type=1079"
            f"&pageNumber={i}#searchform"
            for i in range(1, 10)
        ]
    },
    {
        "scraper": HoistScraper("Plate-loaded"),
        "urls": [
            "https://www.hoistfitness.com/collections/ccat-plate-loaded",
        ]
    },
    {
        "scraper": HoistScraper("Selectorized"),
        "urls": [
            "https://www.hoistfitness.com/collections/ccat-hd-dual-series",
            "https://www.hoistfitness.com/collections/ccat-selectorized",
            "https://www.hoistfitness.com/collections/ccat-multi-jungle-systems",
        ]
    },
    {
        "scraper": LegendFitnessScraper("Selectorized"),
        "urls": [
            "https://www.legendfitness.com/products/"
            "selectorized-equipment/upper-body-selectorized-equipment/",
            "https://www.legendfitness.com/products/"
            "selectorized-equipment/lower-body-and-core-selectorized-equipment/",
            "https://www.legendfitness.com/products/"
            "selectorized-equipment/multi-stack-selectorized-equipment/",
            "https://www.legendfitness.com/products/"
            "selectorized-equipment/combo-stations-selectorized-equipment/",
        ]
    },
    {
        "scraper": LegendFitnessScraper("Plate-loaded"),
        "urls": [
            "https://www.legendfitness.com/products/"
            "all-plate-loaded/upper-body-plate-loaded-equipment/",
            "https://www.legendfitness.com/products/"
            "all-plate-loaded/lower-body-plate-loaded-equipment/",
        ]
    },
    {
        "scraper": LexcoScraper("팔콘", "Selectorized"),
        "urls": [
            "http://www.lexco.kr/shop_list.php?gsp_p=1&gsp_md=shop_goods&gsp_srch_cate=188",
            "http://www.lexco.kr/shop_list.php?gsp_p=2&gsp_md=shop_goods&gsp_srch_cate=188",
        ]
    },
    {
        "scraper": LexcoScraper("마스터 프로", "Selectorized"),
        "urls": [
            "http://www.lexco.kr/shop_list.php?gsp_srch_cate=208",
        ]
    },
    {
        "scraper": LexcoScraper("마스터", "Selectorized"),
        "urls": [
            "http://www.lexco.kr/shop_list.php?gsp_srch_cate=190",
        ]
    },
    {
        "scraper": LexcoScraper("타우러스", "Selectorized"),
        "urls": [
            "http://www.lexco.kr/shop_list.php?gsp_srch_cate=210",
        ]
    },
    {
        "scraper": LexcoScraper("마스터 프로", "Plate-loaded"),
        "urls": [
            "http://www.lexco.kr/shop_list.php?gsp_srch_cate=207",
        ]
    },
    # {
    #     "scraper": LifeFitnessScraper(),
    #     "urls": [
    #         "https://www.lifefitness.com/en-us/catalog?Brand=1056&Type=1079"
    #         f"&pageNumber={i}#searchform"
    #         for i in range(1, 10)
    #     ]
    # },
    {
        "scraper": MatrixScraper("Selectorized"),
        "urls": [
            "https://kr.matrixfitness.com/kor/strength/catalog?series=ultra",
            "https://kr.matrixfitness.com/kor/strength/catalog?series=versa",
            "https://kr.matrixfitness.com/kor/strength/catalog?series=aura",
            "https://kr.matrixfitness.com/kor/strength/catalog?series=go",
        ]
    },
    {
        "scraper": MatrixScraper("Plate-loaded"),
        "urls": [
            "https://kr.matrixfitness.com/kor/strength/catalog?series=xult",
        ]
    },
    {
        "scraper": NautilusScraper("Selectorized"),
        "urls": [
            "https://shop.corehandf.com/collections/inspiration-line?page=1",
            "https://shop.corehandf.com/collections/inspiration-line?page=2",
        ] + [f"https://shop.corehandf.com/collections/impact-line?page={i}" for i in range(1, 4)]
         + [f"https://shop.corehandf.com/collections/instinct-line?page={i}" for i in range(1, 4)]
         + [f"https://shop.corehandf.com/collections/humansport-line"]
    },
    {
        "scraper": NautilusScraper("Plate-loaded"),
        "urls": [
            "https://shop.corehandf.com/collections/leverage-line",
            "https://shop.corehandf.com/collections/plate-loaded-line"
        ]
    },
    {
        "scraper": NewTechScraper("On Him", "Selectorized"),
        "urls": [
            "https://ntws.co.kr/54",
            "https://ntws.co.kr/58",
        ]
    },
    {
        "scraper": NewTechScraper("Advance", "Selectorized"),
        "urls": [
            "https://ntws.co.kr/50",
        ]
    },
    {
        "scraper": NewTechScraper("Plate Load", "Plate-loaded"),
        "urls": [
            "https://ntws.co.kr/50",
        ]
    },
    {
        "scraper": NewTechScraper("M-torture", "Plate-loaded"),
        "urls": [
            "https://ntws.co.kr/51",
            "https://ntws.co.kr/59",
        ]
    },
    {
        "scraper": NewTechScraper("Cable Motion", "Cable"),
        "urls": [
            "https://ntws.co.kr/53",
        ]
    },
    {
        "scraper": PanattaScraper("Monolith", "Selectorized"),
        "urls": [
            f"https://www.panattasport.com/en/monolith/page/{i}/#content"
            for i in range(1, 7)
        ]
    },
    {
        "scraper": PanattaScraper("Fit Evo", "Selectorized"),
        "urls": [
            f"https://www.panattasport.com/en/fit-evo/page/{i}/#content"
            for i in range(1, 7)
        ]
    },
    {
        "scraper": PanattaScraper("Sec", "Selectorized"),
        "urls": [
            f"https://www.panattasport.com/en/sec/page/{i}/#content"
            for i in range(1, 4)
        ]
    },
    {
        "scraper": PanattaScraper("Freeweight Special", "Plate-loaded"),
        "urls": [
            f"https://www.panattasport.com/en/freeweight-special/page/{i}/#content"
            for i in range(1, 6)
        ]
    },
    {
        "scraper": PanattaScraper("Freeweight HP", "Plate-loaded"),
        "urls": [
            f"https://www.panattasport.com/en/freeweight-hp/page/{i}/#content"
            for i in range(1, 5)
        ]
    },
    {
        "scraper": PanattaScraper("Freeweight One", "Plate-loaded"),
        "urls": [
            f"https://www.panattasport.com/en/freeweight-one/page/{i}/#content"
            for i in range(1, 3)
        ]
    },
    {
        "scraper": PanattaScraper("Fantastic", "Selectorized"),
        "urls": [
            "https://www.panattasport.com/en/fantastic"
        ]
    },
    {
        "scraper": PrimeScraper("Evolution", "Selectorized"),
        "urls": ["https://www.primefitnessusa.com/collections/evolution"]
    },
    {
        "scraper": PrimeScraper("Hybrid", "Selectorized"),
        "urls": [f"https://www.primefitnessusa.com/collections/hybrid?page={i}" for i in range(1, 4)]
    },
    {
        "scraper": PrimeScraper("Plate-loaded", "Plate-loaded"),
        "urls": [f"https://www.primefitnessusa.com/collections/plate-loaded-equipment?page={i}" for i in range(1, 3)]
    },
    {
        "scraper": TechnoGymScraper("Plate-loaded"),
        "urls": ["https://www.technogym.com/en-INT/category/plate-loaded"]
    },
    {
        "scraper": TechnoGymScraper("Selectorized"),
        "urls": ["https://www.technogym.com/en-INT/category/selectorized-strength-machines/"]
    },
    {
        "scraper": USPScraper("LeverageSeries", "Plate-loaded"),
        "urls": ["https://www.uspfitness.com/LeverageSeries"]
    },
    {
        "scraper": VilitiScraper("Selectorized"),
        "urls": ["https://kaesun.com/pages/upturn#none"]
    },
    {
        "scraper": VilitiScraper("Selectorized"),
        "urls": ["https://kaesun.com/pages/upturn#none"]
    },
    {
        "scraper": VilitiScraper("Selectorized"),
        "urls": ["https://kaesun.com/pages/upturn#none",
                 "https://kaesun.com/pages/weight#none"]
    },
    {
        "scraper": VilitiScraper("Plate-loaded"),
        "urls": ["https://kaesun.com/pages/xploseries#none",
                 "https://kaesun.com/pages/xplo#none",
                 "https://kaesun.com/pages/plateloaded“"]
    }
]