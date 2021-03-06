require 'spec_helper'

describe 'Карточки,' do

	let(:user) { FactoryGirl.create(:user) }
	let(:other_user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:admin) }

	let!(:card) { FactoryGirl.create(:card, user:user) }
	let!(:other_card) { FactoryGirl.create(:card, user:user) }

	let(:wrong_id) { Card.maximum(:id)+1 }

	let(:category) { FactoryGirl.create(:category) }
	let(:other_category) { FactoryGirl.create(:category) }

	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:cancel_button) { 'Отмена' }
	let(:delete_button) { 'Удалить'}

	subject { page }

	shared_examples_for 'список_карточек' do
		# arguments: the_card1, the_card2
		
		it_should_behave_like 'страница_с_названием' do
			let(:title) {'Карточки'}
			let(:heading) { title }
		end

		it_should_behave_like 'кнопки_удобства'

		it_should_behave_like 'карточка_в_списке' do
			let(:the_card) { the_card1 }
		end

		it_should_behave_like 'карточка_в_списке' do
			let(:the_card) { the_card2 }
		end
	end

	shared_examples_for 'кнопки_карточки' do |mode|
		case mode
		when 'администратор'
			it { should have_xpath("//a[@href='#{edit_card_path(the_card)}' and @title='#{edit_button}']//*[contains(@class,'icon-edit')]") }
			it { should have_xpath("//a[@href='#{card_path(the_card)}' and @title='#{delete_button}']//*[contains(@class,'icon-remove')]") }
		when 'автор'
			it { should have_xpath("//a[@href='#{edit_card_path(the_card)}' and @title='#{edit_button}']//*[contains(@class,'icon-edit')]") }
			it { should_not have_xpath("//a[@href='#{card_path(the_card)}' and @title='#{delete_button}']//*[contains(@class,'icon-remove')]") }
		else
			it { should_not have_xpath("//a[@href='#{edit_card_path(the_card)}' and @title='#{edit_button}']//*[contains(@class,'icon-edit')]") }
			it { should_not have_xpath("//a[@href='#{card_path(the_card)}' and @title='#{delete_button}']//*[contains(@class,'icon-remove')]") }
		end		
	end

	shared_examples_for 'карточка_в_списке' do
		# arguments: the_card

		it { should have_xpath("//*[@id='card#{the_card.id}']//*[contains(@class,'card_title')]//a[@href='#{card_path(the_card)}' and text()='#{the_card.title}']") }
		#it { should have_content( my_sanitize(card.content) ) }
		pending 'тело карточки с my_sanitize()'

		context 'гость,' do
			it_should_behave_like 'кнопки_карточки', 'гость'
		end

		context 'пользователь,' do
			before { 
				sign_in other_user 
				visit cards_path
			}
			it_should_behave_like 'кнопки_карточки', 'пользователь'
		end

		context 'автор,' do
			before { 
				www_user
				visit cards_path
			}
			it_should_behave_like 'кнопки_карточки', 'автор'
		end

		context 'администратор,' do
			before { 
				www_admin
				visit cards_path
			}
			it_should_behave_like 'кнопки_карточки', 'администратор'
		end
	end

	shared_examples_for 'просмотр_карточки' do
		it { should have_css("#card#{the_card.id}") }		
		it { should have_css(".card_title", text: the_card.title) }
		it { should have_css(".card_content") }
		
		it { should have_content(the_card.title) }
		#it { should have_content( my_sanitize(the_card.content) ) }
		pending 'тело карточки с my_sanitize()'
		it { should have_content("от #{the_card.user.name}") }

		it { should_not have_link('Изменить',href: edit_card_path(card)) }
		it { should_not have_link('Удалить',href: card_path(card)) }

		describe 'кнопки управления,'do
			describe 'другой пользователь,' do
				before { 
					sign_in other_user 
					visit card_path(card)
				}
				it { should_not have_link('Изменить',href: edit_card_path(card)) }
				it { should_not have_link('Удалить',href: card_path(card)) }
			end

			describe 'автор,' do
				before { 
					www_user 
					visit card_path(card)
				}
				it { should have_link('Изменить',href: edit_card_path(card)) }
				it { should_not have_link('Удалить',href: card_path(card)) }
			end

			describe 'администратор,' do
				before { 
					www_admin 
					visit card_path(card)
				}
				it { should have_link('Изменить',href: edit_card_path(card)) }
				it { should have_link('Удалить',href: card_path(card)) }
				it { should have_xpath("//a[@data-method='delete' and text()='#{delete_button}' and @href='#{card_path(card)}']")}
			end
		end

		describe 'категории,' do
			let(:all_cats) { [category, other_category] }
			
			before { 
				card.categories = all_cats 
				visit card_path(card)
			}
			
			it 'заголовок области,' do
				expect(page).to have_content('Категория:')
			end

			it 'категория 1' do
				expect(page).to have_link(all_cats.first.name, category_path(all_cats.first))
			end
			
			it 'категория 2' do
				expect(page).to have_link(all_cats.last.name, category_path(all_cats.last))
			end
		end
	end

	shared_examples_for 'кнопки_удобства' do
		it { should have_link('Список', cards_path) }
		
		context 'зарегистрированный пользователь' do
			before { 
				www_user 
				visit cards_path
			}
			it { should have_link('Новая', new_card_path) }
		end
	end

	shared_examples_for 'страница_создания_карточки' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Создание карточки' }
			let(:heading) { title }
		end
		it { should have_field('Название') }
		it { should have_field('Содержимое') }
		it { should have_link(cancel_button, cards_path) }
		it { should have_xpath("//input[@type='submit' and @value='#{create_button}']") }

		#it { should have_field('Категория')}
		it { should have_content('Категория')}

		it { should_not have_selector(:xpath,"//div[text()='Категория:']")}
	end

	shared_examples_for 'страница_изменения_карточки' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Редактирование карточки' }
			let(:heading) { title }
		end
		it { should have_field('Название', with: the_card.title) }
		it { should have_field('Содержимое', with: the_card.content) }
		it { should have_link(cancel_button, href: card_path(the_card.id)) }
		it { should have_xpath("//input[@type='submit' and @value='#{save_button}']") }

		it { should have_field('Категория')}

		it { should_not have_selector(:xpath,"//div[text()='Категория:']")}
	end
	

	describe 'предфильтры,' do
		
		describe 'reject_nil_target(),' do
			describe 'http,' do
				before { get card_path(wrong_id) }
				specify{ expect(response).to redirect_to(cards_path) }
			end

			describe 'www,' do
				before { visit card_path(wrong_id) }
				it_should_behave_like 'flash-сообщение', 'error', 'Запрошенный объект не существует'
				it_should_behave_like 'список_карточек' do
					let(:the_card1) { card }
					let(:the_card2) { card }
				end
			end
		end

		describe 'signed_in_users(),' do
			context 'гость,' do
				before { visit new_card_path }
				it_should_behave_like 'требование_входа'
			end

			context 'пользователь,' do
				before { 
					console_user
					get new_card_path
				}
				specify{ expect(response).to render_template(:new) }
			end
		end

		describe 'editor_users(),' do
			context 'не автор,' do
				before {
					sign_in other_user, no_capybara: true
					get edit_card_path(card)
				}
				specify{ expect(response).to redirect_to(card_path(card)) }
			end

			context 'не автор www,' do
				before {
					sign_in other_user
					visit edit_card_path(card.id)
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Редактирование запрещено'
			end

			context 'автор,' do
				before {
					console_user
					get edit_card_path(card)
				}
				specify{ expect(response).to render_template(:edit) }
			end

			context 'администратор,' do
				before {
					console_admin
					get edit_card_path(card)
				}
				specify{ expect(response).to render_template(:edit) }
			end
		end

		describe 'admin_users(),' do
			context 'не админ' do
				let!(:cards_count) { Card.all.count }
				before {
					console_user
					delete card_path(card)
				}
				specify{ expect(response).to redirect_to(cards_path) }
				specify{ expect(cards_count).to eq Card.all.count }
			end
			
			context 'админ' do
				before { console_admin }
				specify{ expect{ delete card_path(card) }.to change(Card,:count).by(-1) }
			end

			pending 'уведомления предфильтра admin_users пока не тестируются' do
			end
		end
	end


	describe 'список,' do
		before { visit cards_path }
		it_should_behave_like 'список_карточек' do
			let(:the_card1) { card }
			let(:the_card2) { other_card }
		end
	end

	describe 'просмотр,' do
		before { visit card_path(card) }
		it_should_behave_like 'просмотр_карточки' do
			let(:the_card) { card }
		end
	end

	describe 'создание,' do

		pending 'категории при создании'
		pending 'раз-категоризация кардочки'

		let(:card_params) {
			{ card: {
				title: Faker::Lorem.word.capitalize,
				content: Faker::Lorem.paragraph,
				user: user,
			}}
		}

		let(:new_card) { 
			Card.new(
				title: card_params[:card][:title],
				content: card_params[:card][:content],
				user: user,
			)
		}

		describe 'www,' do
			before { 
				www_user 
				visit new_card_path
			}

			describe 'вид,' do
				it_should_behave_like 'страница_создания_карточки'
			end

			describe 'работа,' do
				before {
					fill_in 'Название', with: new_card.title
					fill_in 'Содержимое', with: new_card.content
					click_button create_button
				}
				it_should_behave_like 'просмотр_карточки' do
					let(:the_card) { Card.last }
				end
				it_should_behave_like 'flash-сообщение', 'success', 'Карточка создана'
			end

			pending 'создание карточки с категорией'
		end

		describe 'http,' do
			before {
				console_user
				post cards_path, card_params
			}
			specify{ expect(response).to redirect_to card_path(Card.last) }
		end
	end

	describe 'изменение,' do
		pending 'категории'

		let(:new_title) {card.title + ' ' + Faker::Lorem.word}
		let(:new_content) {Faker::Lorem.paragraph}

		let(:new_card_params) {
			{ card: {
				title: new_title,
				content: new_content,
				user: user,
			}}
		}

		before {
			console_user
			patch card_path(card), new_card_params
		}
		specify{ expect(response).to redirect_to card_path(card) }
		
		specify{ expect(card.reload.title).to eq new_title}
		specify{ expect(card.reload.content).to eq new_content}
	end

	describe 'удаление,' do
		before { console_admin }
		
		describe 'изменение БД,' do
			specify{ expect{ delete card_path(card) }.to change(Card,:count).by(-1) }
		end

		describe 'перенаправление к списку,' do
			before { delete card_path(card) }
			specify{ expect(response).to redirect_to(cards_path) }
		end
	end

	describe 'удаление категории из карточки,' do
		before {
			card.categories = [category]
		}

		context 'не админом,' do
			specify {
				expect{post cc_unbind_path(category.id,card.id)}.not_to change(CcRelation,:count)
			}
		end

		context 'админом,' do
			before {
				console_admin
			}
			specify {
				expect{post cc_unbind_path(category.id,card.id)}.to change(CcRelation,:count).by(-1)
			}
		end
	end

	pending 'тип,' do
	end
end
