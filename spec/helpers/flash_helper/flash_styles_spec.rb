# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashHelper, type: :helper do
  describe "#flash_styles" do
    context "when flash type is :notice" do
      it "returns green styling with checkmark icon" do
        result = helper.flash_styles(:notice)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-green-500")
        expect(result[:icon_color]).to eq("text-green-500")
        expect(result[:icon_path]).to include("M10 18a8 8 0 100-16")
      end
    end

    context "when flash type is :success" do
      it "returns green styling with checkmark icon" do
        result = helper.flash_styles(:success)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-green-500")
        expect(result[:icon_color]).to eq("text-green-500")
        expect(result[:icon_path]).to include("M10 18a8 8 0 100-16")
      end
    end

    context "when flash type is :alert" do
      it "returns red styling with error icon" do
        result = helper.flash_styles(:alert)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-red-500")
        expect(result[:icon_color]).to eq("text-red-500")
        expect(result[:icon_path]).to include("M8.707 7.293a1 1 0 00-1.414 1.414")
      end
    end

    context "when flash type is :error" do
      it "returns red styling with error icon" do
        result = helper.flash_styles(:error)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-red-500")
        expect(result[:icon_color]).to eq("text-red-500")
        expect(result[:icon_path]).to include("M8.707 7.293a1 1 0 00-1.414 1.414")
      end
    end

    context "when flash type is :warning" do
      it "returns yellow styling with warning icon" do
        result = helper.flash_styles(:warning)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-yellow-500")
        expect(result[:icon_color]).to eq("text-yellow-500")
        expect(result[:icon_path]).to include("M8.257 3.099c.765-1.36 2.722-1.36 3.486 0")
      end
    end

    context "when flash type is a string instead of symbol" do
      it "converts string to symbol and returns correct styling" do
        result = helper.flash_styles("notice")

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-green-500")
        expect(result[:icon_color]).to eq("text-green-500")
      end
    end

    context "when flash type is custom/unknown" do
      it "returns default blue info styling" do
        result = helper.flash_styles(:custom)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-blue-500")
        expect(result[:icon_color]).to eq("text-blue-500")
        expect(result[:icon_path]).to include("M18 10a8 8 0 11-16 0")
      end
    end

    context "when flash type is nil" do
      it "returns default blue info styling" do
        result = helper.flash_styles(nil)

        expect(result).to be_a(Hash)
        expect(result[:border_color]).to eq("border-blue-500")
        expect(result[:icon_color]).to eq("text-blue-500")
      end
    end

    context "with various custom flash types" do
      %i[info debug custom_message].each do |type|
        it "returns default blue styling for :#{type}" do
          result = helper.flash_styles(type)

          expect(result[:border_color]).to eq("border-blue-500")
          expect(result[:icon_color]).to eq("text-blue-500")
        end
      end
    end

    context "return value structure" do
      it "always returns a hash with required keys" do
        result = helper.flash_styles(:notice)

        expect(result.keys).to match_array([:border_color, :icon_color, :icon_path])
      end

      it "all values are strings" do
        result = helper.flash_styles(:notice)

        expect(result[:border_color]).to be_a(String)
        expect(result[:icon_color]).to be_a(String)
        expect(result[:icon_path]).to be_a(String)
      end
    end
  end
end
