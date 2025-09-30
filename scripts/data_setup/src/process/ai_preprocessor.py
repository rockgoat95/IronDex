import json
import os
from utils.supabase_manager import SupabaseManager
from utils.gemini_manager import GeminiManager


def get_brand_machines(brand: str) -> list:
    sb_manager = SupabaseManager()
    brand_id_response = sb_manager.client.table("brands").select("id").eq("name", brand).execute()
    if not brand_id_response.data:
        print(f"브랜드 '{brand}'를 찾을 수 없습니다.")
        return []

    brand_id = brand_id_response.data[0]['id']
    machines_response = sb_manager.client.table("machines").select("name, type").eq("brand_id", brand_id).execute()
    return machines_response.data


def get_brand_names() -> list:
    sb_manager = SupabaseManager()
    brand_names_response = sb_manager.client.table("brands").select("name").execute()
    return [brand['name'] for brand in brand_names_response.data] if brand_names_response.data else []


class AIPreprocessor:
    def __init__(self, brand: str, gemini: GeminiManager):
        self.brand = brand
        self.machines = get_brand_machines(brand)
        self.brand_context_prompt = self._prepare_brand_context_prompt()
        self.gemini = gemini

    def _prepare_brand_context_prompt(self) -> str:
        machine_list = "\n".join([f"- {m['name']}" for m in self.machines])
        return f"""
아래는 '{self.brand}' 브랜드의 헬스장 기구 목록입니다.
이후 요청되는 Task 에서 해당 내용을 참고해주세요.
{machine_list}
"""

    def _prepare_prompt(self, machine_name: str, purpose: str) -> str:
        if purpose == "formatting":
            return f"""
머신이름 : {machine_name}

브랜드 : {self.brand}

**위 머신이름을 포매팅 해주세요. !!**
기구이름에는 브랜드명, 라인 명, 모델 명, 코드 (SKU) 가 포함됩니다.
여기서 브랜드명이 포함된다면 제거해주고 '{{라인명}} {{모델 명}} ({{코드}})' 로 포매팅해주세요.
줄임말이 아닌 경우 Capitalize 로 작성해주세요.

라인명은 머신리스트를 통해 추론해주세요.
라인명, 코드가 없으면 괄호는 생략해주세요.
한글이 포함된다면 번역해서 입력해주시고 의미가 중복된다면 제거해주세요.
**반드시 처리된 머신 이름만 출력해주세요.**
**코드가 없는 경우는 많습니다. 무조건 코드가 있다고 가정하지 마세요.**
**숫자이름이 포함된 라인도 있습니다.**
"""
        elif purpose == "translation":
            return f"""
머신이름 : {machine_name}

브랜드 : {self.brand}
**위 머신이름을 한글로 번역해주세요.!! **

기구이름에는 라인 명, 모델 명, 코드 (SKU) 가 순서로 기입되어 있습니다. (포함되지 않는 경우도 있습니다)
라인명은 기존에 한국어인경우 한국어를 쓰고 기존에 영어인 경우 영어로 써주세요

**반드시 번역이 완료된 머신 이름만 출력해주세요.**
"""
        elif purpose == "classification":
            return f"""
머신이름 : {machine_name}

브랜드 : {self.brand}

**위 머신이 어떤 부위를 위한 머신인지 분류해 주세요.!! **
분류는 반드시 다음 카테고리 중 하나로 해주세요:
Chest, Back, Shoulders, Trapezius, Biceps, Triceps, Forearms, Abs, Quadriceps, Hamstrings, Core, Full Body, Hip, Calves, Mitral, ETC

**반드시 주동근 위주로 분류해 주세요.**
 - 너무 개입이 적은 근육은 제외해주세요
**응답은 반드시 카테고리 리스트만 출력해주세요. 예: ["Chest", "Back"]**
"""
        else:
            raise ValueError("Invalid purpose specified.")

    def formatting(self, machine_name: str) -> str:
        prompt = self._prepare_prompt(machine_name, "formatting")
        full_prompt = self.brand_context_prompt + "\n" + prompt
        return self.gemini.generate_content(full_prompt)

    def translation(self, machine_name: str) -> str:
        prompt = self._prepare_prompt(machine_name, "translation")
        full_prompt = self.brand_context_prompt + "\n" + prompt
        return self.gemini.generate_content(full_prompt)

    def classification(self, machine_name: str) -> list[str]:
        prompt = self._prepare_prompt(machine_name, "classification")
        full_prompt = self.brand_context_prompt + "\n" + prompt
        result = self.gemini.generate_content(full_prompt)
        try:
            return json.loads(result)
        except json.JSONDecodeError:
            return []


def preprocess_machine_names():
    output_dir = "/home/user/IronDex/scripts/data_setup/init_data"
    output_path = os.path.join(output_dir, "preprocessed_machine_names.json")

    result = []
    processed_items = set()

    if os.path.exists(output_path):
        try:
            with open(output_path, 'r', encoding='utf-8') as f:
                result = json.load(f)
                processed_items = {(item['brand'], item['name']) for item in result}
            print(f"불러오기 완료: {len(result)}개의 기존 항목을 {output_path}에서 불러왔습니다.")
        except (json.JSONDecodeError, IOError) as e:
            print(f"기존 파일을 불러오는 데 실패했습니다. 처음부터 다시 시작합니다. 오류: {e}")
            result = []
            processed_items = set()

    try:
        brands = get_brand_names()
        print(f"찾은 브랜드: {brands}")
        for brand in brands:
            manager = GeminiManager()
            preprocessor = AIPreprocessor(brand, gemini=manager)
            for machine in preprocessor.machines:
                if (brand, machine['name']) in processed_items:
                    continue

                print(f"처리 중: {brand} - {machine['name']}")

                preprocessed_name = preprocessor.formatting(machine['name'])
                if not preprocessed_name or len(preprocessed_name.strip()) == 0:
                    print(f"경고: {machine['name']}에 대한 포매팅 응답이 비어있습니다.")
                    continue

                translated_name = preprocessor.translation(preprocessed_name)
                if not translated_name or len(translated_name.strip()) == 0:
                    print(f"경고: {preprocessed_name}에 대한 번역 응답이 비어있습니다.")
                    continue

                body_parts = preprocessor.classification(preprocessed_name)
                if not body_parts:
                    print(f"경고: {preprocessed_name}에 대한 분류 응답이 비어있거나 잘못되었습니다.")
                    continue

                print(f"처리 완료: {brand} - {machine['name']} -> {preprocessed_name} -> {translated_name} -> {body_parts}")

                result.append({
                    "brand": brand,
                    "name": machine['name'],
                    "preprocessed_name": preprocessed_name.strip(),
                    "translated_name": translated_name.strip(),
                    "body_parts": body_parts
                })
                processed_items.add((brand, machine['name']))

    except (KeyboardInterrupt, Exception) as e:
        print(f"\n오류 또는 중단 발생: {e}")
    finally:
        if result:
            print("\n결과를 저장하는 중...")
            os.makedirs(output_dir, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(result, f, indent=2, ensure_ascii=False)
            print(f"저장 완료: {len(result)}개의 항목을 {output_path}에 저장했습니다.")
        else:
            print("저장할 결과가 없습니다.")


if __name__ == "__main__":
    preprocess_machine_names()
