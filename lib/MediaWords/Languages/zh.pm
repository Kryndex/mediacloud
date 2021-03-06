package MediaWords::Languages::zh;

#
# Chinese
#
use strict;
use warnings;
use utf8;

use Moose;
with 'MediaWords::Languages::Language';

use Modern::Perl "2015";
use MediaWords::CommonLibs;    # set PYTHONPATH too

# Import McChineseTokenizer
import_python_module( __PACKAGE__, 'mediawords.languages.zh' );

use Readonly;

sub BUILD
{
    my ( $self, $args ) = @_;

    my $tokenizer = MediaWords::Languages::zh::McChineseTokenizer->new();

    # Quick self-test to make sure that Jieba, its dictionaries and Python
    # class are installed and working
    my @self_test_words = $tokenizer->tokenize_sentence_to_words( 'python課程' );
    if ( ( !$self_test_words[ 0 ] ) or $self_test_words[ 1 ] ne '課程' )
    {
        die <<EOF;
Jieba self-test failed; make sure that Jieba is installed and dictionaries are accessible:

    git submodule update --init --recursive
    ./install/

EOF
    }

    $self->{ _chinese_tokenizer } = $tokenizer;
}

sub get_language_code
{
    return 'zh';
}

sub fetch_and_return_stop_words
{
    my $self = shift;
    return $self->_get_stop_words_from_file( 'lib/MediaWords/Languages/resources/zh_stopwords.txt' );
}

sub stem
{
    my $self = shift;

    # Jieba's sentence -> word tokenizer already returns "base forms" of every word
    return \@_;
}

sub get_sentences
{
    my ( $self, $story_text ) = @_;

    my $sentences = $self->{ _chinese_tokenizer }->tokenize_text_to_sentences( $story_text );

    return $sentences;
}

sub tokenize
{
    my ( $self, $sentence ) = @_;

    my $words = $self->{ _chinese_tokenizer }->tokenize_sentence_to_words( $sentence );

    return $words;
}

1;
